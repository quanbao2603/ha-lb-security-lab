# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-sec-ssh-password-rejected

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-sec-ssh-password-rejected` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:12:23+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:12:24+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PasswordAuthentication=yes -o ConnectTimeout=2 ops@172.20.40.11 'hostname' 2>&1 || true
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | TC-MH-SEC-01: Password authentication rejected with Permission denied (publickey) |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.40.11' (ED25519) to the list of known hosts.
ops@172.20.40.11: Permission denied (publickey).
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
