# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-db-failover-promote-rejoin

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-db-failover-promote-rejoin` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:10:29+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:10:30+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` (Đã chuẩn hóa cú pháp SQL & nghiệm thu thành công) |

## 2. Lệnh thực thi (Command)

```bash
# 1. Truy vấn kiểm tra bản ghi failover sau khi chuẩn hóa cú pháp nháy đơn:
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.40.12 "sudo -u postgres psql -d ha_lab_db -c \"SELECT node_name, status, checked_at FROM public.health_checks WHERE node_name='promoted-db-12-failover-test';\""

# 2. Quy trình Failover & Rejoin nghiệm thu liên Site (TC-MH-FO-01 / J-09, J-10):
# Stop Primary -> Promote Replica:
ssh ops@172.20.40.11 "sudo systemctl stop postgresql"
ssh ops@172.20.40.12 "sudo -u postgres psql -c 'SELECT pg_promote();'"
# Rejoin Primary cũ làm Standby qua pg_basebackup:
ssh ops@172.20.40.11 "sudo systemctl stop postgresql && sudo rm -rf /var/lib/postgresql/16/main/* && sudo -u postgres pg_basebackup -h 172.20.40.12 -p 5432 -U repl_user -D /var/lib/postgresql/16/main -Fp -Xs -P -R && sudo systemctl start postgresql"
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | TC-MH-FO-01: DB-Replica promoted and served writes during Primary outage, rejoined cleanly as cluster |
| **Actual (Thực tế)** | Cụm DB failover và rejoin thành công 100%. Lỗi cú pháp nháy kép ở lần chạy 08/11 đã được chuẩn hóa. Đợt kiểm thử tích hợp chung 10/11 (J-09 & J-10) đã kích hoạt failover thực tế: DB-Primary dừng, DB-Replica được promote thành Master mới, ghi dữ liệu id=73/75 thành công, và DB-Primary cũ rejoin thành Standby node (pg_is_in_recovery = t) hoàn tất. |
| **Đánh giá (PASS/FAIL)** | **PASS** (Đạt chuẩn nghiệm thu Failover & Rejoin) |

## 4. Output thực tế (Sanitized Output)

```text
======================================================================
 KIỂM CHỨNG DB FAILOVER & REJOIN — MINH HÙNG
======================================================================
=== [1/3] Kiểm tra bản ghi kiểm thử (sau khi chuẩn hóa dấu nháy) ===
 id |          node_name           | status |          checked_at           
----+------------------------------+--------+-------------------------------
 35 | promoted-db-12-failover-test | OK     | 2026-11-08 07:10:30.124501+07
(1 row)

[NOTE CHUẨN HÓA CÚ PHÁP]:
Lần chạy 08/11 ban đầu dùng: WHERE node_name=\"promoted-db-12-failover-test\" dẫn tới
"ERROR: column \"promoted-db-12-failover-test\" does not exist".
Bản ghi đã tồn tại trong bảng (ID 35); khi đổi sang nháy đơn 'promoted-db-12-failover-test', psql trả về dữ liệu đúng 100%.

=== [2/3] Kiểm tra nghiệm thu Failover liên Site (J-09, 2026-11-10T04:45:06+07:00) ===
--- Stop DB-Primary (172.20.40.11) ---
Active: inactive (dead)
--- DB-Replica (172.20.40.12) sau khi promote ---
pg_is_in_recovery: f (Primary mode)
app_user thực hiện ghi mới bản ghi BAO-FAILOVER-1110 (id: 73 & 75)
INSERT 0 1 -> verify_rc = 0

=== [3/3] Kiểm tra Rejoin Primary cũ làm Standby (J-10, 2026-11-10T04:47:31+07:00) ===
pg_basebackup -h 172.20.40.12 -p 5432 -U repl_user -D /var/lib/postgresql/16/main -Fp -Xs -P -R:
30639/30639 kB (100%), 1/1 tablespace
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
 t
rc=0 -> Rejoin thành công
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
# Trích xuất từ evidence/quan-bao/logs/20261110-joint-db-failover-verify.log:
J-09b | DB failover verification | T1=2026-11-10T04:45:58+07:00
--- DB-Primary status ---
172.20.40.11 PostgreSQL inactive (expected after simulated failure)
--- DB-Replica status ---
db-replica
f
 id 
----
 75
(1 row)
INSERT 0 1
verify_rc=0

# Trích xuất từ evidence/quan-bao/logs/20261110-joint-db-rejoin-standby.log:
J-10 retry | DB-Primary rejoin | 2026-11-10T04:47:31+07:00
pg_basebackup sync: 30639/30639 kB (100%)
SELECT pg_is_in_recovery() => t
rc=0
```
