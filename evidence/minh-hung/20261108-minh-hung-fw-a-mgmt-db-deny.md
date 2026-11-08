# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-fw-a-mgmt-db-deny

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-fw-a-mgmt-db-deny` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:05:44+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:05:46+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.10 'nc -zv -w 2 172.20.40.11 5432 2>&1 || echo BLOCKED_BY_DEFAULT_DENY' && ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.2 'sudo journalctl -k --grep="FW-DEFAULT-DENY" -n 2 --no-pager'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | FW-99: MGMT -> DB-Primary port 5432 is blocked and kernel log records FW-DEFAULT-DENY |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.50.10' (ED25519) to the list of known hosts.
nc: connect to 172.20.40.11 port 5432 (tcp) timed out: Operation now in progress
BLOCKED_BY_DEFAULT_DENY
Warning: Permanently added '172.20.50.2' (ED25519) to the list of known hosts.
Nov 08 07:05:46 fw-a kernel: [FW-DEFAULT-DENY:] IN=eth4 OUT=eth3 MACSRC=00:0c:29:80:0f:41 MACDST=00:0c:29:96:55:68 MACPROTO=0800 SRC=172.20.50.10 DST=172.20.40.11 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=13416 DF PROTO=TCP SPT=37366 DPT=5432 SEQ=380555358 ACK=0 WINDOW=64240 RES=0x00 SYN URGP=0 OPT (020405B40402080A274C29F20000000001030307) 
Nov 08 07:05:45 fw-a kernel: [FW-DEFAULT-DENY:] IN=eth4 OUT=eth3 MACSRC=00:0c:29:80:0f:41 MACDST=00:0c:29:96:55:68 MACPROTO=0800 SRC=172.20.50.10 DST=172.20.40.11 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=13415 DF PROTO=TCP SPT=37366 DPT=5432 SEQ=380555358 ACK=0 WINDOW=64240 RES=0x00 SYN URGP=0 OPT (020405B40402080A274C25ED0000000001030307) 
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
