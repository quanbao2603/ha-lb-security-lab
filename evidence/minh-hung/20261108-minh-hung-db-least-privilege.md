# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-db-least-privilege

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-db-least-privilege` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T06:52:07+07:00` |
| **Thời gian kết thúc** | `2026-11-08T06:52:08+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.12 'sudo -u postgres psql -d ha_lab_db -c "SELECT * FROM public.health_checks;" && sudo -u postgres psql -h 172.20.40.11 -U app_user -d ha_lab_db -c "DELETE FROM public.health_checks;" 2>&1 || true'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | Seed row visible on replica; app_user DELETE returns permission denied |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.40.12' (ED25519) to the list of known hosts.
 id | node_name  | status |          checked_at           
----+------------+--------+-------------------------------
  1 | db-primary | OK     | 2026-11-08 00:31:16.988526+07
(1 row)

ERROR:  permission denied for table health_checks
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
