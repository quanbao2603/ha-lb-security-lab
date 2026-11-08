# Runbook: Dừng DB-Primary, Promote DB-Replica, Backup và Khôi phục

## 1. Kịch bản Failover: Dừng DB-Primary & Promote DB-Replica

### Bước 1: Dừng DB-Primary (`172.20.40.11`) để mô phỏng sự cố hoặc bảo trì
Tránh tình trạng Split-Brain bằng cách đảm bảo dịch vụ PostgreSQL trên Primary đã dừng hoàn toàn trước khi promote:
```bash
# Chạy trên DB-Primary (172.20.40.11)
sudo systemctl stop postgresql
sudo systemctl status postgresql --no-pager
```

### Bước 2: Kiểm tra độ trễ WAL trên DB-Replica (`172.20.40.12`) trước khi Promote
```bash
sudo -u postgres psql -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
```

### Bước 3: Promote DB-Replica (`172.20.40.12`) lên làm Primary mới
Thực hiện **một trong hai cách** chuẩn dưới đây trên `172.20.40.12`:

- **Cách A — Dùng hàm SQL `SELECT pg_promote()` (Khuyên dùng trên PostgreSQL 12+)**:
```bash
sudo -u postgres psql -c "SELECT pg_promote(wait => true, wait_seconds => 30);"
```

- **Cách B — Dùng công cụ CLI `pg_ctl promote`**:
```bash
sudo -u postgres /usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/16/main promote
```

### Bước 4: Xác nhận DB-Replica đã thoát chế độ Recovery (Read-Write)
```bash
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
# Kết quả kỳ vọng: f (false -> Đã trở thành Primary Read-Write)

# Kiểm tra ghi thử từ app_user
psql -h 172.20.40.12 -U app_user -d ha_lab_db -c "INSERT INTO health_checks(node_name, status) VALUES ('db-replica-promoted', 'OK');"
```
Sau bước này, cập nhật cấu hình kết nối DB trên Web-A (`172.20.20.21`) và Web-B (`172.20.20.22`) trỏ về `172.20.40.12`.

---

## 2. Quy trình Backup (`pg_basebackup` & `pg_dump`)

### 2.1. Logical Backup từng Database bằng `pg_dump`
Dùng cho lưu trữ bản chụp logic gọn nhẹ (schema + data):
```bash
BACKUP_DIR="/var/backups/postgresql"
sudo mkdir -p "$BACKUP_DIR"
sudo chown postgres:postgres "$BACKUP_DIR"

sudo -u postgres pg_dump -Fc -Z 6 -d ha_lab_db \
  -f "$BACKUP_DIR/ha_lab_db_$(date +%Y%m%d_%H%M%S).dump"
```

### 2.2. Physical Backup toàn cụm bằng `pg_basebackup`
Dùng để dựng lại nhanh một node Standby hoặc khôi phục toàn bộ cluster:
```bash
sudo -u postgres pg_basebackup \
  -h 172.20.40.11 \
  -U repl_user \
  -D "/var/backups/postgresql/base_$(date +%Y%m%d_%H%M%S)" \
  -Ft -z -Xs -P
```

---

## 3. Quy trình Khôi phục (Restore & Re-join Standby)

### 3.1. Khôi phục Database từ bản `pg_dump` (`.dump`)
```bash
sudo -u postgres pg_restore --clean --if-exists -d ha_lab_db \
  /var/backups/postgresql/ha_lab_db_<TIMESTAMP>.dump
```

### 3.2. Khôi phục node Primary cũ (`172.20.40.11`) thành Standby mới
Sau khi `172.20.40.12` đã được promote làm Primary mới, đưa `172.20.40.11` quay lại cụm làm Standby:
```bash
# Chạy trên 172.20.40.11
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/16/main/*

sudo -u postgres pg_basebackup \
  -h 172.20.40.12 \
  -p 5432 \
  -U repl_user \
  -D /var/lib/postgresql/16/main \
  -Fp -Xs -P -R

sudo systemctl start postgresql
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
# Kỳ vọng: t (true)
```
