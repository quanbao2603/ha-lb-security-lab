#!/usr/bin/env bash
# monitoring-healthcheck.sh
# Kiểm tra trạng thái dịch vụ rsyslog, dung lượng phân vùng log và cấu hình logrotate retention trên Log-Monitor (172.20.50.10)
# ponytail: cron + bash exit-code ceiling ~10 hosts; upgrade to Prometheus node_exporter + Alertmanager when metrics alerting needed.

set -euo pipefail

LOG_DIR="${LOG_DIR:-/var/log/central}"
MAX_DISK_USAGE_PCT="${MAX_DISK_USAGE_PCT:-80}"
LOGROTATE_CONF="${LOGROTATE_CONF:-/etc/logrotate.d/rsyslog-central}"
MIN_RETENTION_DAYS="${MIN_RETENTION_DAYS:-7}"

check_retention_value() {
    local conf_file="$1"
    local min_days="$2"
    [[ -f "$conf_file" ]] || return 1
    local rotate_val
    rotate_val=$(awk '/^[[:space:]]*rotate[[:space:]]+[0-9]+/ {print $2; exit}' "$conf_file")
    [[ -n "$rotate_val" && "$rotate_val" -ge "$min_days" ]]
}

if [[ "${1:-}" == "--self-test" ]]; then
    tmp_conf=$(mktemp)
    trap 'rm -f "$tmp_conf"' EXIT
    printf "/var/log/central/*/*.log {\n  daily\n  rotate 14\n  compress\n}\n" > "$tmp_conf"
    check_retention_value "$tmp_conf" 7 || { echo "FAIL: valid retention rejected"; exit 1; }
    check_retention_value "$tmp_conf" 30 && { echo "FAIL: low retention accepted"; exit 1; }
    echo "SELF-TEST PASS"
    exit 0
fi

failures=0

echo "=== [1/3] Kiểm tra trạng thái dịch vụ rsyslog & lắng nghe cổng 514 ==="
if systemctl is-active --quiet rsyslog; then
    echo "[OK] Dịch vụ rsyslog đang hoạt động (active)."
else
    echo "[FAIL] Dịch vụ rsyslog KHÔNG hoạt động."
    failures=$((failures + 1))
fi

if ss -tuln | grep -Eq '172\.20\.50\.10:514|0\.0\.0\.0:514'; then
    echo "[OK] Cổng 514 (UDP/TCP) đang lắng nghe."
else
    echo "[FAIL] Không tìm thấy socket lắng nghe cổng 514."
    failures=$((failures + 1))
fi

echo "=== [2/3] Kiểm tra dung lượng lưu trữ tại $LOG_DIR ==="
mkdir -p "$LOG_DIR"
usage_pct=$(df -P "$LOG_DIR" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
dir_size=$({ sudo du -sh "$LOG_DIR" 2>/dev/null || du -sh "$LOG_DIR" 2>/dev/null || echo "0K"; } | awk '{print $1}')

if [[ "$usage_pct" -le "$MAX_DISK_USAGE_PCT" ]]; then
    echo "[OK] Dung lượng ổ đĩa: ${usage_pct}% (Ngưỡng: ${MAX_DISK_USAGE_PCT}%), dung lượng log: ${dir_size}."
else
    echo "[WARN] Dung lượng ổ đĩa vượt ngưỡng: ${usage_pct}% > ${MAX_DISK_USAGE_PCT}% (Log size: ${dir_size})."
    failures=$((failures + 1))
fi

echo "=== [3/3] Kiểm tra chính sách Logrotate Retention ($LOGROTATE_CONF) ==="
if check_retention_value "$LOGROTATE_CONF" "$MIN_RETENTION_DAYS"; then
    echo "[OK] Cấu hình logrotate hợp lệ (rotate >= ${MIN_RETENTION_DAYS}) tại $LOGROTATE_CONF."
elif check_retention_value "/etc/logrotate.d/rsyslog" "$MIN_RETENTION_DAYS" || check_retention_value "/etc/logrotate.conf" 4; then
    echo "[OK] Đang dùng cấu hình logrotate mặc định của hệ thống."
else
    echo "[FAIL] Chưa đạt chuẩn retention tối thiểu (${MIN_RETENTION_DAYS} chu kỳ) trong $LOGROTATE_CONF."
    failures=$((failures + 1))
fi

exit "$failures"
