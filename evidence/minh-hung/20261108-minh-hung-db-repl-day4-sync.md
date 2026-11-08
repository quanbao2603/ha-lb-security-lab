# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-db-repl-day4-sync

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-db-repl-day4-sync` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:06:41+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:06:42+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `1` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.11 'export PATH=$PATH:/usr/sbin:/sbin; /opt/lab/scripts/verify-db-replication.sh' && ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.12 'sudo -u postgres psql -d ha_lab_db -c "SELECT node_name, status, checked_at FROM public.health_checks WHERE node_name=\"tc-mh-db-01-day4\";"'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | Day 4: lag_bytes=0, streaming WAL active, record tc-mh-db-01-day4 replicated to DB-Replica |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `1` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **FAIL** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.40.11' (ED25519) to the list of known hosts.
======================================================================
 KIỂM TRA POSTGRESQL REPLICATION — MINH HÙNG (2026-11-08T07:06:43+07:00)
 Primary: 172.20.40.11 | Replica: 172.20.40.12 | DB: ha_lab_db
======================================================================
=== [1/2] Kiểm tra DB-Primary (172.20.40.11:5432) ===
[PASS] DB-Primary (172.20.40.11) đang ở chế độ Read-Write (pg_is_in_recovery = f)
Output pg_stat_replication: 172.20.40.12|streaming|async|0
[PASS] DB-Primary đang truyền WAL (state = streaming) tới Replica 172.20.40.12
Warning: Permanently added '172.20.40.12' (ED25519) to the list of known hosts.
ERROR:  column "tc-mh-db-01-day4" does not exist
LINE 1: ...cked_at FROM public.health_checks WHERE node_name="tc-mh-db-...
                                                             ^
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
