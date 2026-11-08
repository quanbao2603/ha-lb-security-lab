#!/usr/bin/env bash
# ==============================================================================
# collect-evidence.sh
# Owner      : Minh Hùng (scripts/minh-hung)
# Mục đích   : Thu thập bằng chứng kiểm thử kèm timestamp chuẩn
#              YYYYMMDD-minh-hung-<test-name>.md và tự động ẩn thông tin nhạy cảm.
# Cách dùng  : ./collect-evidence.sh <test-name> "<command>" ["<expected-result>"]
# ponytail   : Flat Markdown evidence generator ceiling ~100 runs; upgrade to
#              JSONL + SQLite evidence indexer if aggregating across >2 members.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EVIDENCE_DIR="${EVIDENCE_DIR:-${REPO_ROOT}/evidence/minh-hung}"
OWNER="minh-hung"

validate_test_name() {
    local name="$1"
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

redact_secrets() {
    sed -E \
        -e 's/(ts[k]ey-[a-zA-Z0-9-]+)/***REDACTED_TSKEY***/g' \
        -e 's/(PASSWORD|password|passwd|secret|token)[[:space:]]*[:=][[:space:]]*[^[:space:]"'"'"']+/\1=***REDACTED***/g'
}

build_evidence_filename() {
    local date_str="$1"
    local test_name="$2"
    printf "%s-%s-%s.md" "$date_str" "$OWNER" "$test_name"
}

if [[ "${1:-}" == "--self-test" ]]; then
    validate_test_name "fw-deny-wan-db" || { echo "FAIL: valid test-name rejected"; exit 1; }
    validate_test_name "../bad_name" && { echo "FAIL: path traversal test-name accepted"; exit 1; }
    fname="$(build_evidence_filename "20261107" "db-repl-sync")"
    [[ "$fname" == "20261107-minh-hung-db-repl-sync.md" ]] || { echo "FAIL: wrong filename $fname"; exit 1; }
    redacted="$(printf "token=sensitive_auth_123456 password=mysecret\n" | redact_secrets)"
    [[ "$redacted" != *"123456"* && "$redacted" != *"mysecret"* ]] || { echo "FAIL: secret leak in redact_secrets"; exit 1; }
    echo "SELF-TEST PASS: collect-evidence.sh"
    exit 0
fi

if [[ $# -lt 2 ]]; then
    echo "Cách dùng: $0 <test-name> "<command>" ["<expected-result>"]" >&2
    echo "Ví dụ   : $0 fw-deny-wan-db "nc -zv -w 3 172.20.40.11 5432" "Connection timed out + log FW-DENY-WAN-DIRECT"" >&2
    exit 2
fi

TEST_NAME="$1"
CMD_STRING="$2"
EXPECTED_TEXT="${3:-Theo kịch bản trong lab/testing/minh-hung/test-cases-minh-hung.md}"

if ! validate_test_name "$TEST_NAME"; then
    echo "[ERROR] <test-name> chỉ được chứa chữ thường, số và dấu gạch ngang (ví dụ: fw-deny-wan-db)." >&2
    exit 2
fi

mkdir -p "$EVIDENCE_DIR"

DATE_STAMP="$(date +%Y%m%d)"
START_ISO="$(date -Is)"
HOST_NAME="$(hostname 2>/dev/null || echo unknown-host)"
HOST_IPS="$(ip -4 -br addr show 2>/dev/null | awk '{print $1":"$3}' | paste -sd ', ' - || echo unknown-ip)"
OUT_FILE="${EVIDENCE_DIR}/$(build_evidence_filename "$DATE_STAMP" "$TEST_NAME")"

set +e
RAW_OUTPUT="$(eval "$CMD_STRING" 2>&1)"
CMD_EXIT_CODE=$?
set -e

END_ISO="$(date -Is)"
SAFE_OUTPUT="$(printf "%s\n" "$RAW_OUTPUT" | redact_secrets)"

KERNEL_FW_LOGS="$(journalctl -k --grep='FW-' -n 15 --no-pager 2>/dev/null | redact_secrets || echo 'Không có quyền đọc journalctl hoặc không chạy trên node Firewall.')"

{
    echo "# Biên Bản Bằng Chứng Kiểm Thử: ${DATE_STAMP}-${OWNER}-${TEST_NAME}"
    echo ""
    echo "## 1. Thông tin chung (Metadata)"
    echo ""
    echo "| Trường thông tin | Giá trị ghi nhận |"
    echo "| :--- | :--- |"
    echo "| **Mã biên bản** | \`${DATE_STAMP}-${OWNER}-${TEST_NAME}\` |"
    echo "| **Người thực hiện** | Minh Hùng |"
    echo "| **Thời gian bắt đầu** | \`${START_ISO}\` |"
    echo "| **Thời gian kết thúc** | \`${END_ISO}\` |"
    echo "| **Máy thực hiện (Host)** | \`${HOST_NAME}\` |"
    echo "| **Địa chỉ IP trên máy** | \`${HOST_IPS}\` |"
    echo "| **Mã thoát lệnh (Exit Code)** | \`${CMD_EXIT_CODE}\` |"
    echo ""
    echo "## 2. Lệnh thực thi (Command)"
    echo ""
    echo "\`\`\`bash"
    echo "${CMD_STRING}"
    echo "\`\`\`"
    echo ""
    echo "## 3. Đối chiếu Expected vs Actual"
    echo ""
    echo "| Tiêu chí | Nội dung |"
    echo "| :--- | :--- |"
    echo "| **Expected (Kỳ vọng)** | ${EXPECTED_TEXT} |"
    echo "| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát \`${CMD_EXIT_CODE}\` (xem chi tiết output và log bên dưới). |"
    if [[ "$CMD_EXIT_CODE" -eq 0 ]]; then
        echo "| **Đánh giá (PASS/FAIL)** | **PASS** |"
    else
        echo "| **Đánh giá (PASS/FAIL)** | **FAIL** |"
    fi
    echo ""
    echo "## 4. Output thực tế (Sanitized Output)"
    echo ""
    echo "\`\`\`text"
    printf "%s\n" "${SAFE_OUTPUT}"
    echo "\`\`\`"
    echo ""
    echo "## 5. Log trích xuất đối chiếu (Firewall / Syslog)"
    echo ""
    echo "\`\`\`text"
    printf "%s\n" "${KERNEL_FW_LOGS}"
    echo "\`\`\`"
} > "$OUT_FILE"

echo "[OK] Đã lưu bằng chứng kiểm thử tại: ${OUT_FILE}"
