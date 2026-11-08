# Cấu hình PostgreSQL Streaming Replication (DB-Primary & DB-Replica)

## 1. Thông số kiến trúc Database Zone
- **DB-Primary**: `172.20.40.11` (Port `5432/tcp`)
- **DB-Replica**: `172.20.40.12` (Port `5432/tcp`)
- **Web-A / Web-B (App Tier)**: `172.20.20.21`, `172.20.20.22`
- **Log-Monitor**: `172.20.50.10`

---

## 2. Cấu hình trên DB-Primary (`172.20.40.11`)

### 2.1. `postgresql.conf` (Bind-Address & Streaming WAL)
Chỉ bind vào localhost và địa chỉ IP riêng của DB-Primary:

```ini
# Bind-address giới hạn đúng interface Database VLAN
listen_addresses = '127.0.0.1, 172.20.40.11'
port = 5432
password_encryption = scram-sha-256

# Cấu hình Streaming Replication
wal_level = replica
max_wal_senders = 5
max_replication_slots = 5
wal_keep_size = 512MB
hot_standby = on

# Ghi log phục vụ tập trung về Log-Monitor (172.20.50.10)
logging_collector = off
log_destination = 'syslog'
syslog_facility = 'LOCAL0'
syslog_ident = 'postgres'
log_connections = on
log_disconnections = on
```

### 2.2. `pg_hba.conf` (Least-Privilege Host-Based Authentication)
Chỉ mở kết nối ứng dụng cho **Web-A (`172.20.20.21/32`)**, **Web-B (`172.20.20.22/32`)** và kết nối replication cho **DB-Replica (`172.20.40.12/32`)**:

```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer

# App Tier: chỉ cho phép Web-A và Web-B truy cập ha_lab_db bằng app_user
host    ha_lab_db       app_user        172.20.20.21/32         scram-sha-256
host    ha_lab_db       app_user        172.20.20.22/32         scram-sha-256

# Replication: chỉ cho phép DB-Replica (và DB-Primary khi đảo chiều)
host    replication     repl_user       172.20.40.12/32         scram-sha-256
host    replication     repl_user       172.20.40.11/32         scram-sha-256

# Từ chối mọi kết nối khác
host    all             all             0.0.0.0/0               reject
```

### 2.3. Khởi tạo User, Database và Physical Replication Slot
```bash
sudo -u postgres psql -f /opt/lab/database/init-least-privilege.sql
sudo -u postgres psql -c "SELECT pg_create_physical_replication_slot('replica_slot_1');"
sudo systemctl reload postgresql
```

---

## 3. Cấu hình trên DB-Replica (`172.20.40.12`)

### 3.1. Đồng bộ dữ liệu nền từ DB-Primary bằng `pg_basebackup`
```bash
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/16/main/*

# Kéo base backup + tạo tự động standby.signal và primary_conninfo
sudo -u postgres pg_basebackup \
  -h 172.20.40.11 \
  -p 5432 \
  -U repl_user \
  -D /var/lib/postgresql/16/main \
  -Fp -Xs -P -R \
  -S replica_slot_1
```

### 3.2. Kiểm tra `postgresql.conf` trên DB-Replica
Đảm bảo `listen_addresses` trên DB-Replica bind đúng IP của nó để sẵn sàng nhận traffic khi promote:
```ini
listen_addresses = '127.0.0.1, 172.20.40.12'
hot_standby = on
```

Khởi động dịch vụ:
```bash
sudo systemctl start postgresql
```

---

## 4. Kiểm tra trạng thái Replication

- **Trên DB-Primary (`172.20.40.11`)**:
```sql
SELECT client_addr, state, sync_state, sent_lsn, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;
```
*(Kỳ vọng: `client_addr = 172.20.40.12`, `state = streaming`)*

- **Trên DB-Replica (`172.20.40.12`)**:
```sql
SELECT pg_is_in_recovery(), status, sender_host FROM pg_stat_wal_receiver;
```
*(Kỳ vọng: `pg_is_in_recovery() = t`, `status = streaming`, `sender_host = 172.20.40.11`)*
