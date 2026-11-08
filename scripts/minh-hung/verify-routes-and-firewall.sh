#!/usr/bin/env bash
# ==============================================================================
# verify-routes-and-firewall.sh
# Owner      : Minh Hùng (scripts/minh-hung)
# Mục đích   : Kiểm tra bảng định tuyến, IP forwarding, trạng thái nftables
#              và kiểm thử kết nối các port được phép (ALLOW) / bị chặn (DENY).
# ponytail   : Sequential nc/curl probes ceiling ~20 rules; upgrade to automated
#              pytest + scapy packet assertions if rule matrix exceeds 50 rules.
# ==============================================================================

set -euo pipefail
export PATH="$PATH:/usr/sbin:/sbin"

ROLE="${ROLE:-auto}"                 # auto | firewall | transit | wan-client | web-node | db-node
VIP_IP="${VIP_IP:-172.20.20.100}"
WEB_A_IP="${WEB_A_IP:-172.20.20.21}"
WEB_B_IP="${WEB_B_IP:-172.20.20.22}"
DB_PRI_IP="${DB_PRI_IP:-172.20.40.11}"
DB_REP_IP="${DB_REP_IP:-172.20.40.12}"
MGMT_LOG_IP="${MGMT_LOG_IP:-172.20.50.10}"
TIMEOUT_SEC="${TIMEOUT_SEC:-3}"

EXPECTED_SUBNETS=("172.20.10.0/24" "172.20.20.0/24" "172.20.30.0/24" "172.20.40.0/24" "172.20.50.0/24")
REQUIRED_NFT_PREFIXES=(
    "FW-ALLOW-WAN-VIP:"
    "FW-DENY-WAN-DIRECT:"
    "FW-ALLOW-LB-WEB:"
    "FW-ALLOW-WEB-DB:"
    "FW-ALLOW-DB-REPL:"
    "FW-ALLOW-MGMT-SSH:"
    "FW-DEFAULT-DENY:"
)

validate_ip_forward_output() {
    local val="$1"
    [[ "$val" == "1" ]]
}

validate_nft_ruleset_text() {
    local ruleset="$1"
    [[ "$ruleset" == *"policy drop"* ]] || return 1
    for prefix in "${REQUIRED_NFT_PREFIXES[@]}"; do
        [[ "$ruleset" == *"$prefix"* ]] || return 1
    done
    return 0
}

if [[ "${1:-}" == "--self-test" ]]; then
    validate_ip_forward_output "1" || { echo "FAIL: ip_forward=1 rejected"; exit 1; }
    validate_ip_forward_output "0" && { echo "FAIL: ip_forward=0 accepted"; exit 1; }

    sample_nft="chain forward { type filter hook forward priority filter; policy drop;
        log prefix \"FW-ALLOW-WAN-VIP: \"
        log prefix \"FW-DENY-WAN-DIRECT: \"
        log prefix \"FW-ALLOW-LB-WEB: \"
        log prefix \"FW-ALLOW-WEB-DB: \"
        log prefix \"FW-ALLOW-DB-REPL: \"
        log prefix \"FW-ALLOW-MGMT-SSH: \"
        log prefix \"FW-DEFAULT-DENY: \"
    }"
    validate_nft_ruleset_text "$sample_nft" || { echo "FAIL: valid sample nftables ruleset rejected"; exit 1; }
    validate_nft_ruleset_text "chain forward { policy accept; }" && { echo "FAIL: insecure ruleset accepted"; exit 1; }
    echo "SELF-TEST PASS: verify-routes-and-firewall.sh"
    exit 0
fi

failures=0
pass_msg() { printf "[PASS] %s\n" "$1"; }
warn_msg() { printf "[WARN] %s\n" "$1"; }
fail_msg() { printf "[FAIL] %s\n" "$1"; failures=$((failures + 1)); }

probe_tcp() {
    local host="$1"
    local port="$2"
    if command -v nc >/dev/null 2>&1; then
        nc -z -w "$TIMEOUT_SEC" "$host" "$port" >/dev/null 2>&1
    else
        timeout "$TIMEOUT_SEC" bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1
    fi
}

expect_allow() {
    local desc="$1" host="$2" port="$3"
    if probe_tcp "$host" "$port"; then
        pass_msg "ALLOW đúng kỳ vọng: ${desc} (${host}:${port})"
    else
        fail_msg "ALLOW thất bại: ${desc} (${host}:${port} không kết nối được)"
    fi
}

expect_deny() {
    local desc="$1" host="$2" port="$3"
    if probe_tcp "$host" "$port"; then
        fail_msg "VI PHẠM CHÍNH SÁCH (Lẽ ra phải DENY): ${desc} (${host}:${port} vẫn mở!)"
    else
        pass_msg "DENY đúng kỳ vọng: ${desc} (${host}:${port} đã bị chặn)"
    fi
}

echo "======================================================================"
echo " KIỂM TRA ROUTING & FIREWALL — MINH HÙNG ($(date -Is))"
echo " Host: $(hostname) | Role: ${ROLE}"
echo "======================================================================"

echo ""
echo "=== [1/4] Kiểm tra bảng định tuyến (Routing Table & Tailscale) ==="
route_out="$(ip route show 2>/dev/null || true)"
echo "$route_out"
for subnet in "${EXPECTED_SUBNETS[@]}"; do
    if grep -Fq "${subnet%/*}" <<<"$route_out"; then
        pass_msg "Đã có route cho phân vùng ${subnet}"
    else
        warn_msg "Chưa thấy route trực tiếp/tĩnh cho ${subnet} trên node này"
    fi
done

if command -v tailscale >/dev/null 2>&1; then
    echo "--- Trạng thái Tailscale (chỉ cho phép trên Transit VM) ---"
    tailscale status || warn_msg "Tailscale chưa đăng nhập hoặc đang dừng"
fi

echo ""
echo "=== [2/4] Kiểm tra IP Forwarding (net.ipv4.ip_forward) ==="
ip_fwd="$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)"
if validate_ip_forward_output "$ip_fwd"; then
    pass_msg "net.ipv4.ip_forward = 1 (Đã bật định tuyến gói tin)"
else
    if [[ "$ROLE" == "firewall" || "$ROLE" == "transit" || "$(hostname)" =~ (firewall|fw|transit) ]]; then
        fail_msg "net.ipv4.ip_forward = ${ip_fwd} (Bắt buộc bằng 1 trên Firewall/Transit)"
    else
        pass_msg "net.ipv4.ip_forward = ${ip_fwd} (Đúng cho endpoint không làm router)"
    fi
fi

echo ""
echo "=== [3/4] Kiểm tra dịch vụ & tập luật nftables ==="
if command -v nft >/dev/null 2>&1 && { [[ "$ROLE" == "firewall" ]] || [[ "$(hostname)" =~ (firewall|fw) ]]; }; then
    if systemctl is-active --quiet nftables; then
        pass_msg "Dịch vụ systemd nftables đang active"
    else
        fail_msg "Dịch vụ systemd nftables KHÔNG active"
    fi

    ruleset_dump="$(sudo nft list ruleset 2>/dev/null || nft list ruleset 2>/dev/null || true)"
    if validate_nft_ruleset_text "$ruleset_dump"; then
        pass_msg "Tập luật nftables có policy drop và đầy đủ 7 log prefix chuẩn"
    else
        fail_msg "Tập luật nftables thiếu policy drop hoặc thiếu log prefix chuẩn"
    fi
else
    warn_msg "Bỏ qua kiểm tra trực tiếp daemon nftables (node hiện tại không phải Firewall)"
fi

echo ""
echo "=== [4/4] Kiểm thử kết nối Port theo Role (ALLOW vs DENY) ==="
case "$ROLE" in
    wan-client)
        expect_allow "WAN -> VIP HTTP"  "$VIP_IP" 80
        expect_allow "WAN -> VIP HTTPS" "$VIP_IP" 443
        expect_deny  "WAN -> Web-A trực tiếp (Bypass LB)" "$WEB_A_IP" 80
        expect_deny  "WAN -> Web-B trực tiếp (Bypass LB)" "$WEB_B_IP" 80
        expect_deny  "WAN -> DB-Primary 5432" "$DB_PRI_IP" 5432
        expect_deny  "WAN -> DB-Replica 5432" "$DB_REP_IP" 5432
        expect_deny  "WAN -> MGMT SSH 22"     "$MGMT_LOG_IP" 22
        ;;
    web-node)
        expect_allow "Web -> DB-Primary 5432" "$DB_PRI_IP" 5432
        expect_allow "Web -> DB-Replica 5432" "$DB_REP_IP" 5432
        expect_deny  "Web -> MGMT SSH 22"     "$MGMT_LOG_IP" 22
        ;;
    db-node)
        expect_allow "DB-Primary <-> DB-Replica 5432" "$DB_REP_IP" 5432
        ;;
    *)
        echo "Chạy kiểm tra nhanh tới VIP (${VIP_IP}:80) và DB-Primary (${DB_PRI_IP}:5432)..."
        if probe_tcp "$VIP_IP" 80; then
            pass_msg "Kết nối tới VIP ${VIP_IP}:80 khả dụng"
        else
            warn_msg "Không kết nối được VIP ${VIP_IP}:80 từ vị trí hiện tại"
        fi
        ;;
esac

echo ""
echo "======================================================================"
if [[ "$failures" -eq 0 ]]; then
    echo " KẾT LUẬN: TẤT CẢ KIỂM TRA ĐẠT YÊU CẦU (0 lỗi)"
else
    echo " KẾT LUẬN: PHÁT HIỆN ${failures} LỖI CẤU HÌNH / CHÍNH SÁCH"
fi
echo "======================================================================"
exit "$failures"
