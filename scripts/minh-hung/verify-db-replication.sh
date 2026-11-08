#!/usr/bin/env bash
# ==============================================================================
# verify-db-replication.sh
# Owner      : Minh Hùng (scripts/minh-hung)
# Mục đích   : Kiểm tra trạng thái pg_stat_replication trên DB-Primary (172.20.40.11)
#              và pg_is_in_recovery() trên DB-Replica (172.20.40.12).
# ponytail   : Direct psql CLI polling ceiling 2 DB nodes; upgrade to Patroni
#              REST API / prometheus postgres_exporter when auto-failover is added.
# ==============================================================================

set -euo pipefail

PRIMARY_IP="${PRIMARY_IP:-172.20.40.11}"
REPLICA_IP="${REPLICA_IP:-172.20.40.12}"
PG_PORT="${PG_PORT:-5432}"
PG_SUPERUSER="${PG_SUPERUSER:-postgres}"
APP_DB="${APP_DB:-ha_lab_db}"
MODE="${MODE:-auto}"  # auto | primary | replica | remote

parse_primary_repl_state() {
    local out="$1"
    local expected_replica_ip="$2"
    [[ "$out" == *"${expected_replica_ip}|streaming"* ]]
}

parse_replica_recovery_state() {
    local out="$1"
    [[ "$(echo "$out" | tr -d '[:space:]')" == "t" ]]
}

if [[ "${1:-}" == "--self-test" ]]; then
    parse_primary_repl_state "172.20.40.12|streaming|async|0" "172.20.40.12" || {
        echo "FAIL: valid primary streaming output rejected"
        exit 1
    }
    parse_primary_repl_state "172.20.40.12|startup|async|0" "172.20.40.12" && {
        echo "FAIL: non-streaming state accepted"
        exit 1
    }
    parse_replica_recovery_state " t " || {
        echo "FAIL: valid recovery state 't' rejected"
        exit 1
    }
    parse_replica_recovery_state "f" && {
        echo "FAIL: non-recovery state 'f' accepted as replica"
        exit 1
    }
    echo "SELF-TEST PASS: verify-db-replication.sh"
    exit 0
fi

failures=0
pass_msg() { printf "[PASS] %s\n" "$1"; }
fail_msg() { printf "[FAIL] %s\n" "$1"; failures=$((failures + 1)); }

run_psql_local() {
    local sql="$1"
    sudo -u "$PG_SUPERUSER" psql -p "$PG_PORT" -At -F '|' -c "$sql"
}

run_psql_target() {
    local target_ip="$1"
    local sql="$2"
    if ip -4 addr show 2>/dev/null | grep -Fq "$target_ip"; then
        run_psql_local "$sql"
    else
        psql -h "$target_ip" -p "$PG_PORT" -U "$PG_SUPERUSER" -d postgres -At -F '|' -c "$sql"
    fi
}

check_primary() {
    echo "=== [1/2] Kiểm tra DB-Primary (${PRIMARY_IP}:${PG_PORT}) ==="
    local is_rec
    is_rec="$(run_psql_target "$PRIMARY_IP" "SELECT pg_is_in_recovery();" 2>/dev/null || echo "ERR")"
    if [[ "$(echo "$is_rec" | tr -d '[:space:]')" == "f" ]]; then
        pass_msg "DB-Primary (${PRIMARY_IP}) đang ở chế độ Read-Write (pg_is_in_recovery = f)"
    else
        fail_msg "DB-Primary (${PRIMARY_IP}) KHÔNG ở chế độ Primary (pg_is_in_recovery = ${is_rec})"
    fi

    local repl_info
    repl_info="$(run_psql_target "$PRIMARY_IP" "SELECT client_addr, state, sync_state, pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes FROM pg_stat_replication;" 2>/dev/null || true)"
    echo "Output pg_stat_replication: ${repl_info:-<trống>}"

    if parse_primary_repl_state "$repl_info" "$REPLICA_IP"; then
        pass_msg "DB-Primary đang truyền WAL (state = streaming) tới Replica ${REPLICA_IP}"
    else
        fail_msg "Không tìm thấy phiên streaming replication từ ${PRIMARY_IP} tới ${REPLICA_IP}"
    fi
}

check_replica() {
    echo "=== [2/2] Kiểm tra DB-Replica (${REPLICA_IP}:${PG_PORT}) ==="
    local is_rec
    is_rec="$(run_psql_target "$REPLICA_IP" "SELECT pg_is_in_recovery();" 2>/dev/null || echo "ERR")"
    if parse_replica_recovery_state "$is_rec"; then
        pass_msg "DB-Replica (${REPLICA_IP}) đang ở chế độ Hot Standby (pg_is_in_recovery = t)"
    else
        fail_msg "DB-Replica (${REPLICA_IP}) KHÔNG ở chế độ Standby (pg_is_in_recovery = ${is_rec})"
    fi

    local wal_rcv
    wal_rcv="$(run_psql_target "$REPLICA_IP" "SELECT status, sender_host, sender_port, written_lsn, flushed_lsn FROM pg_stat_wal_receiver;" 2>/dev/null || true)"
    echo "Output pg_stat_wal_receiver: ${wal_rcv:-<trống>}"

    if [[ "$wal_rcv" == *"streaming|${PRIMARY_IP}"* ]]; then
        pass_msg "WAL receiver trên ${REPLICA_IP} đang nhận stream từ ${PRIMARY_IP}"
    else
        fail_msg "WAL receiver trên ${REPLICA_IP} không ở trạng thái streaming từ ${PRIMARY_IP}"
    fi
}

echo "======================================================================"
echo " KIỂM TRA POSTGRESQL REPLICATION — MINH HÙNG ($(date -Is))"
echo " Primary: ${PRIMARY_IP} | Replica: ${REPLICA_IP} | DB: ${APP_DB}"
echo "======================================================================"

if [[ "$MODE" == "primary" ]] || { [[ "$MODE" == "auto" ]] && ip -4 addr show 2>/dev/null | grep -Fq "$PRIMARY_IP"; }; then
    check_primary
elif [[ "$MODE" == "replica" ]] || { [[ "$MODE" == "auto" ]] && ip -4 addr show 2>/dev/null | grep -Fq "$REPLICA_IP"; }; then
    check_replica
else
    check_primary
    echo ""
    check_replica
fi

exit "$failures"
