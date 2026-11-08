# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-rt-transit-b-antibypass

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-rt-transit-b-antibypass` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T06:51:59+07:00` |
| **Thời gian kết thúc** | `2026-11-08T06:52:02+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.20.6 'nc -zv -w 2 172.20.40.11 22 2>&1 || echo BLOCKED_AS_EXPECTED'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | Direct SSH from Transit-B to DB-Primary is dropped by Firewall-A |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.20.6' (ED25519) to the list of known hosts.
nc: connect to 172.20.40.11 port 22 (tcp) timed out: Operation now in progress
BLOCKED_AS_EXPECTED
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
