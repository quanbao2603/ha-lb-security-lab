# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-db-repl-streaming

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-db-repl-streaming` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T06:52:06+07:00` |
| **Thời gian kết thúc** | `2026-11-08T06:52:07+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.11 'export PATH=$PATH:/usr/sbin:/sbin; /opt/lab/scripts/verify-db-replication.sh'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | DB-Primary in read-write mode, DB-Replica receiving streaming WAL |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.40.11' (ED25519) to the list of known hosts.
======================================================================
 KIỂM TRA POSTGRESQL REPLICATION — MINH HÙNG (2026-11-08T06:52:08+07:00)
 Primary: 172.20.40.11 | Replica: 172.20.40.12 | DB: ha_lab_db
======================================================================
=== [1/2] Kiểm tra DB-Primary (172.20.40.11:5432) ===
[PASS] DB-Primary (172.20.40.11) đang ở chế độ Read-Write (pg_is_in_recovery = f)
Output pg_stat_replication: 172.20.40.12|streaming|async|0
[PASS] DB-Primary đang truyền WAL (state = streaming) tới Replica 172.20.40.12
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
