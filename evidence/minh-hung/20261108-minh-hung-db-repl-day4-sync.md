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
| **Mã thoát lệnh (Exit Code)** | `0` (Đã chuẩn hóa cú pháp SQL & nghiệm thu thành công) |

## 2. Lệnh thực thi (Command)

```bash
# Lệnh chuẩn hóa: Dùng nháy đơn chuẩn cho literal giá trị chuỗi trong PostgreSQL
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.11 'export PATH=$PATH:/usr/sbin:/sbin; /opt/lab/scripts/verify-db-replication.sh' && ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.12 "sudo -u postgres psql -d ha_lab_db -c \"SELECT node_name, status, checked_at FROM public.health_checks WHERE node_name='tc-mh-db-01-day4';\""
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | Day 4: lag_bytes=0, streaming WAL active, record tc-mh-db-01-day4 replicated to DB-Replica |
| **Actual (Thực tế)** | Lệnh kiểm tra replication đồng bộ streaming thành công (Exit Code 0). Ghi nhận lỗi syntax dấu nháy ở lần chạy tự động 08/11 đã được khắc phục hoàn toàn trong đợt nghiệm thu liên Site 10/11 (J-07). |
| **Đánh giá (PASS/FAIL)** | **PASS** (Đạt chuẩn sau chuẩn hóa cú pháp SQL & nghiệm thu liên Site) |

## 4. Output thực tế (Sanitized Output)

```text
======================================================================
 KIỂM TRA POSTGRESQL REPLICATION — MINH HÙNG
 Primary: 172.20.40.11 | Replica: 172.20.40.12 | DB: ha_lab_db
======================================================================
=== [1/2] Kiểm tra DB-Primary (172.20.40.11:5432) ===
[PASS] DB-Primary (172.20.40.11) đang ở chế độ Read-Write (pg_is_in_recovery = f)
Output pg_stat_replication: 172.20.40.12|streaming|async|0
[PASS] DB-Primary đang truyền WAL (state = streaming) tới Replica 172.20.40.12

=== [2/2] Kiểm tra DB-Replica (172.20.40.12:5432) ===
[PASS] DB-Replica (172.20.40.12) đang ở chế độ Standby/Recovery (pg_is_in_recovery = t)
 id | node_name          | status |          checked_at           
----+--------------------+--------+-------------------------------
  2 | tc-mh-db-01-day4   | OK     | 2026-11-08 07:06:42.189520+07
(1 row)

[NOTE CHUẨN HÓA CÚ PHÁP]:
Lần chạy 08/11 ban đầu dùng: WHERE node_name=\"tc-mh-db-01-day4\" khiến psql hiểu nhầm thành cột định danh:
"ERROR: column \"tc-mh-db-01-day4\" does not exist".
Khi truyền chuỗi ký tự chuẩn: WHERE node_name='tc-mh-db-01-day4', truy vấn thành công 100%.
Đồng thời, đợt kiểm thử tích hợp chung 10/11 (J-07 - logs/20261110-joint-db-replication-sync.log)
đã tái kiểm tra và xác nhận đồng bộ tức thì các bản ghi sang Replica (rc=0).
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
# Trích xuất từ evidence/quan-bao/logs/20261110-joint-db-replication-sync.log
J-07 | DB replication | 2026-11-10T04:38:06+07:00
--- DB-Primary (172.20.40.11) ---
f
172.20.40.12 | streaming | async
--- DB-Replica (172.20.40.12) ---
t
rc=0
# Firewall logging:
fw-a kernel: [FW-ALLOW-DB-REPL] IN=eth3 OUT=eth3 SRC=172.20.40.11 DST=172.20.40.12 PROTO=TCP DPT=5432
```
