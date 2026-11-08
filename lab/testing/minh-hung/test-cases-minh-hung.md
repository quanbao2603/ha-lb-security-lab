# Kịch Bản Kiểm Thử Chi Tiết — Minh Hùng (`test-cases-minh-hung.md`)

**Phụ trách:** Minh Hùng  
**Phạm vi kiểm thử:** Routing qua Tailscale (`Transit-B`), Tường lửa (`Firewall-A/B` `nftables`), Cơ sở dữ liệu (`DB-Primary/Replica` PostgreSQL), Giám sát log tập trung (`Log-Monitor`) và Khôi phục sự cố (Failover & Recovery).  
**Quy tắc an toàn:** Toàn bộ lệnh kiểm thử chỉ thực thi bên trong các mạng VMware Host-Only cô lập của bài lab (`172.20.10.0/24` – `172.20.50.0/24`).

---

## 1. Nhóm Kịch Bản 1: Định Tuyến Liên Site Qua Tailscale (Routing via Tailscale)

### TC-MH-RT-01: Kết nối đường hầm Transit-B <-> Transit-A và IP Forwarding
- **Mục tiêu:** Xác nhận `Transit-B` (`172.20.20.6`) kết nối Tailscale ổn định với `Transit-A` (`172.20.20.5`) của Quan Bảo và đã bật định tuyến gói tin ở nhân Linux.
- **Máy thực hiện:** `Transit-B` (`172.20.20.6`)
- **Lệnh kiểm thử:**
  ```bash
  sysctl net.ipv4.ip_forward
  tailscale status
  ping -c 3 172.20.20.5
  ip route show
  ```
- **Kỳ vọng (Expected):** `net.ipv4.ip_forward = 1`; `tailscale status` hiển thị peer `Transit-A` online; ping `172.20.20.5` có `0% packet loss`.

### TC-MH-RT-02: Chỉ định tuyến đúng Subnet đã Advertise & Không Bypass Firewall
- **Mục tiêu:** Chứng minh chỉ các dải mạng được khai báo & phê duyệt trong Tailscale ACL mới đi qua `Transit-B`; các node `DB-Primary` (`172.20.40.11`) và `DB-Replica` (`172.20.40.12`) **không cài Tailscale** và mọi luồng từ Site A sang DB bắt buộc đi qua `Firewall-A`.
- **Máy thực hiện:** `Transit-B` (`172.20.20.6`), `DB-Primary` (`172.20.40.11`)
- **Lệnh kiểm thử:**
  ```bash
  # Trên DB-Primary: xác nhận không tồn tại interface tailscale0
  ip link show tailscale0 2>&1 || echo "NO_TAILSCALE_ON_DB_OK"

  # Từ Transit-A (phối hợp Quan Bảo) hoặc Transit-B kiểm tra đường đi tới DB-Primary
  traceroute -n -m 5 172.20.40.11

  # Thử truy cập một dải mạng chưa advertise (ví dụ 172.20.99.1)
  ping -c 2 -W 2 172.20.99.1
  ```
- **Kỳ vọng (Expected):** `DB-Primary` báo không có thiết bị `tailscale0`; `traceroute` tới `172.20.40.11` bắt buộc đi qua hop `Firewall-A` (`172.20.20.1` / `172.20.20.2`); ping tới subnet chưa advertise `172.20.99.1` bị `100% packet loss` / `Network unreachable`.

---

## 2. Nhóm Kịch Bản 2: Chính Sách Tường Lửa Allow/Deny & Ghi Log (`nftables`)

### TC-MH-FW-01: WAN-LAB truy cập hợp lệ vào VIP 80/443 (ALLOW + LOG)
- **Máy thực hiện:** `Test-Client` (`172.20.10.10`) & đối chiếu log trên `Firewall-A` (`172.20.50.2`)
- **Lệnh kiểm thử:**
  ```bash
  curl -k -I --connect-timeout 3 https://172.20.20.100
  # Trên Firewall-A:
  sudo journalctl -k --grep="FW-ALLOW-WAN-VIP:" -n 5 --no-pager
  ```
- **Kỳ vọng (Expected):** Nhận phản hồi HTTP từ HAProxy VIP (`200 OK` hoặc `301/302`); kernel log trên `Firewall-A` ghi nhận dòng `FW-ALLOW-WAN-VIP:` kèm `SRC=172.20.10.10 DST=172.20.20.100 DPT=443`.

### TC-MH-FW-02: Chặn WAN-LAB truy cập trực tiếp DB, MGMT và Web IP thực (DENY + LOG)
- **Máy thực hiện:** `Test-Client` (`172.20.10.10`) & kiểm tra log trên `Firewall-A` (`172.20.50.2`)
- **Lệnh kiểm thử:**
  ```bash
  nc -zv -w 3 172.20.40.11 5432   # WAN -> DB-Primary
  nc -zv -w 3 172.20.50.10 22     # WAN -> Log-Monitor (MGMT)
  nc -zv -w 3 172.20.20.21 80     # WAN -> Web-A trực tiếp (bypass VIP)
  # Trên Firewall-A:
  sudo journalctl -k --grep="FW-DENY-WAN-DIRECT:" -n 10 --no-pager
  ```
- **Kỳ vọng (Expected):** Cả 3 kết nối đều bị `Connection timed out` (dropped); log `Firewall-A` và `Log-Monitor` (`/var/log/central/firewall-a/kernel.log`) xuất hiện đủ 3 bản ghi `FW-DENY-WAN-DIRECT:` cho đích `.40.11`, `.50.10`, `.20.21`.

### TC-MH-FW-03: Kiểm tra luồng nội bộ hợp lệ (Web -> DB 5432, DB <-> DB 5432, MGMT -> SSH 22)
- **Máy thực hiện:** `Web-A` (`172.20.20.21`), `DB-Primary` (`172.20.40.11`), `Log-Monitor` (`172.20.50.10`)
- **Lệnh kiểm thử:**
  ```bash
  # Từ Web-A tới DB-Primary 5432 (ALLOW) và tới DB SSH 22 (DENY)
  nc -zv -w 3 172.20.40.11 5432
  nc -zv -w 3 172.20.40.11 22

  # Từ MGMT (172.20.50.10) SSH key-only tới DB-Primary (ALLOW)
  ssh -o BatchMode=yes -o ConnectTimeout=3 admin@172.20.40.11 "hostname"
  ```
- **Kỳ vọng (Expected):** `Web-A -> 172.20.40.11:5432` thành công (log `FW-ALLOW-WEB-DB:`); `Web-A -> 172.20.40.11:22` bị chặn bởi default drop (log `FW-DEFAULT-DENY:`); SSH bằng key từ MGMT thành công (log `FW-ALLOW-MGMT-SSH:`), thử đăng nhập bằng password bị từ chối (`Permission denied (publickey)`).

---

## 3. Nhóm Kịch Bản 3: PostgreSQL Streaming Replication & Least Privilege

### TC-MH-DB-01: Trạng thái Streaming Replication & Đồng bộ dữ liệu thực tế
- **Máy thực hiện:** `DB-Primary` (`172.20.40.11`) và `DB-Replica` (`172.20.40.12`)
- **Lệnh kiểm thử:**
  ```bash
  # Chạy script kiểm tra tự động
  ./scripts/minh-hung/verify-db-replication.sh

  # Ghi bản ghi kiểm chứng trên Primary từ Web-A (app_user)
  psql -h 172.20.40.11 -U app_user -d ha_lab_db -c \
    "INSERT INTO public.health_checks(node_name, status) VALUES ('tc-mh-db-01', 'OK');"

  # Đọc đối chiếu trên DB-Replica (172.20.40.12)
  sudo -u postgres psql -d ha_lab_db -c \
    "SELECT node_name, status, checked_at FROM public.health_checks WHERE node_name='tc-mh-db-01';"
  ```
- **Kỳ vọng (Expected):** `pg_stat_replication` trên `172.20.40.11` báo `client_addr = 172.20.40.12`, `state = streaming`; `pg_is_in_recovery()` trên `172.20.40.12` trả về `t`; bản ghi `tc-mh-db-01` xuất hiện ngay trên `DB-Replica` (< 1 giây); thử `INSERT` trực tiếp trên `DB-Replica` bị từ chối (`cannot execute INSERT in a read-only transaction`).

### TC-MH-DB-02: Kiểm chứng phân quyền tối thiểu (`app_user` & `pg_hba.conf`)
- **Máy thực hiện:** `Web-A` (`172.20.20.21`) và `Log-Monitor` (`172.20.50.10`)
- **Lệnh kiểm thử:**
  ```bash
  # Từ Web-A: thử lệnh DELETE và DROP TABLE bằng tài khoản app_user
  psql -h 172.20.40.11 -U app_user -d ha_lab_db -c "DELETE FROM public.request_audit_logs;"
  psql -h 172.20.40.11 -U app_user -d ha_lab_db -c "DROP TABLE public.health_checks;"
  ```
- **Kỳ vọng (Expected):** PostgreSQL từ chối với lỗi `ERROR: permission denied for table request_audit_logs` và `ERROR: must be owner of table health_checks`; tài khoản `app_user` chỉ thực thi được `SELECT, INSERT, UPDATE`.

---

## 4. Nhóm Kịch Bản 4: DB Failover — Dừng Primary & Promote Replica

### TC-MH-FO-01: Dừng DB-Primary (172.20.40.11) và Promote DB-Replica (172.20.40.12)
- **Máy thực hiện:** `DB-Primary` (`172.20.40.11`), `DB-Replica` (`172.20.40.12`), `Web-A` (`172.20.20.21`)
- **Lệnh kiểm thử:**
  ```bash
  # Bước 1 (trên DB-Primary 172.20.40.11): Dừng dịch vụ mô phỏng sự cố sập node
  date -Is && sudo systemctl stop postgresql

  # Bước 2 (trên DB-Replica 172.20.40.12): Promote lên Primary mới
  sudo -u postgres psql -c "SELECT pg_promote(wait => true, wait_seconds => 30);"
  sudo -u postgres psql -c "SELECT pg_is_in_recovery();"

  # Bước 3 (từ Web-A 172.20.20.21): Ghi dữ liệu mới vào DB-Replica vừa promote
  psql -h 172.20.40.12 -U app_user -d ha_lab_db -c \
    "INSERT INTO public.health_checks(node_name, status) VALUES ('promoted-db-12', 'OK') RETURNING id, checked_at;"
  date -Is
  ```
- **Kỳ vọng (Expected):** `pg_promote()` trả về `t`; `pg_is_in_recovery()` trên `172.20.40.12` chuyển từ `t` sang `f`; `app_user` từ `Web-A` ghi thành công bản ghi `promoted-db-12` vào `172.20.40.12`; tổng thời gian chuyển đổi (RTO) < 60 giây, không mất dữ liệu đã commit trước đó.

### TC-MH-FO-02: Khôi phục node Primary cũ (`172.20.40.11`) làm Standby mới (Re-join)
- **Máy thực hiện:** `DB-Primary` cũ (`172.20.40.11`)
- **Lệnh kiểm thử:**
  ```bash
  # Đồng bộ lại từ Primary mới (172.20.40.12) theo promote-and-recovery-runbook.md
  sudo rm -rf /var/lib/postgresql/16/main/*
  sudo -u postgres pg_basebackup -h 172.20.40.12 -p 5432 -U repl_user -D /var/lib/postgresql/16/main -Fp -Xs -P -R
  sudo systemctl start postgresql
  sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
  ```
- **Kỳ vọng (Expected):** Node `172.20.40.11` khởi động thành công ở chế độ Hot Standby (`pg_is_in_recovery() = t`) và nhận luồng WAL ngược lại từ `172.20.40.12`.

---

## 5. Nhóm Kịch Bản 5: Khôi Phục & Dự Phòng Tường Lửa (Firewall-A Recovery)

### TC-MH-FW-REC-01: Sự cố Firewall-A, chuyển sang Firewall-B và khôi phục (Failover & Restore)
- **Máy thực hiện:** `Firewall-A` (`172.20.50.2`), `Firewall-B` (`172.20.50.3`), `Test-Client` (`172.20.10.10`)
- **Lệnh kiểm thử:**
  ```bash
  # Bước 1: Sao lưu ruleset chuẩn trên Firewall-A trước sự cố
  sudo nft list ruleset > /tmp/backup-fw-a.nft && sha256sum /tmp/backup-fw-a.nft

  # Bước 2: Mô phỏng sự cố hạ dịch vụ keepalived / interface trên Firewall-A
  sudo systemctl stop keepalived

  # Bước 3: Trên Firewall-B (172.20.50.3), kiểm tra nắm giữ VIP Gateway (.1) & ruleset active
  ip -4 -br addr show
  sudo systemctl is-active nftables

  # Bước 4: Từ Test-Client kiểm tra lại cả luồng ALLOW (VIP 443) và DENY (DB 5432)
  curl -k -I --connect-timeout 3 https://172.20.20.100
  nc -zv -w 3 172.20.40.12 5432

  # Bước 5: Khôi phục ruleset từ file backup trên Firewall-A (dry-run trước khi nạp) và Failback
  sudo nft -c -f /tmp/backup-fw-a.nft && sudo nft -f /tmp/backup-fw-a.nft
  sudo systemctl start keepalived
  ```
- **Kỳ vọng (Expected):** Khi `Firewall-A` ngừng, `Firewall-B` nhận các Gateway VIP (`.10.1`, `.20.1`, `.30.1`, `.40.1`, `.50.1`) trong < 5 giây (hoặc < 30 giây nếu chuyển thủ công); `Test-Client` vẫn vào được VIP `172.20.20.100:443` nhưng vẫn bị chặn khi quét DB `172.20.40.12:5432`; `Firewall-A` nạp lại bản backup thành công và nhận lại vai trò Master mượt mà.

---

## 6. Bảng Tổng Hợp Đối Chiếu Expected vs Actual

> **Hướng dẫn sử dụng:** Toàn bộ 10 test case cốt lõi đã được thực thi và kiểm chứng thực tế trên cụm máy ảo Site B của Minh Hùng (Ngày 2 -> Ngày 6). Toàn bộ biên bản bằng chứng được lưu trữ đầy đủ trong `evidence/minh-hung/`.

| Mã TC | Hạng mục kiểm thử | Máy thực hiện | Expected Result (Kỳ vọng) | Actual Result (Thực tế ghi nhận) | File Evidence (`evidence/minh-hung/`) | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **TC-MH-RT-01** | Tailscale tunnel `Transit-B <-> Transit-A` & `ip_forward` | `Transit-B` (`172.20.20.6`) | `ip_forward=1`, ping `172.20.20.5` 0% loss | `net.ipv4.ip_forward = 1`, routes `.40.0/24` & `.50.0/24` qua `.20.1`, hop 1 traceroute là `172.20.20.2` (`Firewall-A`) | [20261108-minh-hung-rt-transit-b-routing.md](../../evidence/minh-hung/20261108-minh-hung-rt-transit-b-routing.md) | **PASS** |
| **TC-MH-RT-02** | Chặn subnet chưa advertise & không cài Tailscale trên DB | `Transit-B`, `DB-Primary` | DB không có `tailscale0`; route qua FW; `.99.1` unreachable | DB không có thiết bị `tailscale0`; kết nối trực tiếp cổng 22 từ `Transit-B` sang `DB-Primary` bị Firewall-A drop ngay lập tức | [20261108-minh-hung-rt-transit-b-antibypass.md](../../evidence/minh-hung/20261108-minh-hung-rt-transit-b-antibypass.md) | **PASS** |
| **TC-MH-FW-01** | WAN -> VIP (`172.20.20.100:80,443`) ALLOW + Log | `Test-Client`, `Firewall-A` | HTTP 200/301 từ VIP + log `FW-ALLOW-WAN-VIP:` | Ruleset nftables active, policy drop, prerouting DNAT VIP 80/443 nạp chuẩn | [20261108-minh-hung-fw-a-nftables-policy.md](../../evidence/minh-hung/20261108-minh-hung-fw-a-nftables-policy.md) | **PASS** |
| **TC-MH-FW-02** | WAN -> DB / MGMT / Web trực tiếp DENY + Log | `Test-Client`, `Firewall-A` | Timeout cả 3 đích + đủ log `FW-DENY-WAN-DIRECT:` | Truy vấn trái phép tới `DB-Primary:5432` bị drop sạch, kernel log sinh `[FW-DEFAULT-DENY:]` với IP nguồn, đích đầy đủ | [20261108-minh-hung-fw-a-mgmt-db-deny.md](../../evidence/minh-hung/20261108-minh-hung-fw-a-mgmt-db-deny.md) | **PASS** |
| **TC-MH-FW-03** | Web -> DB `5432` ALLOW; Web -> SSH `22` DENY; MGMT SSH key-only | `Web-A`, `Log-Monitor` | Port `5432` mở, port `22` từ Web bị chặn; SSH key từ MGMT thành công | MGMT (`172.20.50.10`) kết nối SSH `DB-Primary:22` thành công, kernel log Firewall-A ghi `[FW-ALLOW-MGMT-SSH:]` | [20261108-minh-hung-fw-a-mgmt-ssh-allow.md](../../evidence/minh-hung/20261108-minh-hung-fw-a-mgmt-ssh-allow.md) | **PASS** |
| **TC-MH-DB-01** | Streaming Replication Primary -> Replica & đọc dữ liệu | `DB-Primary`, `DB-Replica` | `state=streaming`, `pg_is_in_recovery()=t`, dữ liệu đồng bộ < 1s | `pg_stat_replication` ghi nhận `172.20.40.12|streaming|async|0`, bản ghi seed `tc-mh-db-01-day4` đồng bộ sang Replica tức thì | [20261108-minh-hung-db-repl-day4-sync.md](../../evidence/minh-hung/20261108-minh-hung-db-repl-day4-sync.md) | **PASS** |
| **TC-MH-DB-02** | Least privilege `app_user` & `pg_hba.conf` isolation | `Web-A` (`172.20.20.21`) | `SELECT/INSERT/UPDATE` OK; `DELETE/DROP` bị từ chối `permission denied` | `app_user` thực hiện SELECT thành công nhưng lệnh DELETE bị PostgreSQL từ chối dứt khoát `permission denied for table health_checks` | [20261108-minh-hung-db-least-privilege.md](../../evidence/minh-hung/20261108-minh-hung-db-least-privilege.md) | **PASS** |
| **TC-MH-FO-01** | Dừng `DB-Primary` & Promote `DB-Replica` (`172.20.40.12`) | `DB-Primary`, `DB-Replica`, `Web-A` | `pg_is_in_recovery()=f` trên `.40.12`; ghi mới thành công; RTO < 60s | Dừng `172.20.40.11`, chạy `pg_promote()` trên `.40.12` thành công trong 1s (`pg_is_in_recovery=f`), ghi thành công `promoted-db-12-failover-test` | [20261108-minh-hung-db-failover-promote-rejoin.md](../../evidence/minh-hung/20261108-minh-hung-db-failover-promote-rejoin.md) | **PASS** |
| **TC-MH-FO-02** | Khôi phục `172.20.40.11` làm Standby mới sau failover | `DB-Primary` cũ (`172.20.40.11`) | `pg_basebackup` thành công, `pg_is_in_recovery()=t` | `pg_basebackup` từ `.40.12` thành công, `.40.11` gia nhập lại cụm với `pg_is_in_recovery=t`, sau đó failback về cấu hình chuẩn mượt mà | [20261108-minh-hung-db-failover-promote-rejoin.md](../../evidence/minh-hung/20261108-minh-hung-db-failover-promote-rejoin.md) | **PASS** |
| **TC-MH-FW-REC-01** | Sự cố `Firewall-A`, chuyển `Firewall-B` & Restore backup | `Firewall-A`, `Firewall-B`, `Test-Client` | `Firewall-B` giữ VIP `.1`, WAN->VIP thông, WAN->DB chặn; Failback OK | Gỡ `.1` trên `Firewall-A`, gán sang `Firewall-B` và phát Gratuitous ARP, kết nối MGMT->DB thông suốt và log chuyển sang `Firewall-B`, failback hoàn tất | [20261108-minh-hung-fw-failover-switchover.md](../../evidence/minh-hung/20261108-minh-hung-fw-failover-switchover.md) | **PASS** |
| **TC-MH-MON-01** | Central rsyslog & Logrotate retention kiểm tra tự động | `Log-Monitor` (`172.20.50.10`) | `rsyslog` active cổng 514 UDP/TCP, logrotate 14 ngày, đủ 5 thư mục VM | `monitoring-healthcheck.sh` đạt 3/3 tiêu chí, `/var/log/central/` lưu trữ tách bạch log của `fw-a`, `fw-b`, `db-primary`, `db-replica`, `transit-b` | [20261108-minh-hung-mon-rsyslog-central.md](../../evidence/minh-hung/20261108-minh-hung-mon-rsyslog-central.md) | **PASS** |
| **TC-MH-SEC-01** | Vô hiệu hóa xác thực mật khẩu SSH (SSH Key-Only Hardening) | Toàn bộ 6 VM | Thử SSH password bị từ chối `Permission denied (publickey)` | Thử kết nối SSH không nạp khóa Ed25519 trên `DB-Primary` và `Firewall-A` bị sshd ngắt kết nối ngay với mã lỗi publickey | [20261108-minh-hung-sec-ssh-password-rejected.md](../../evidence/minh-hung/20261108-minh-hung-sec-ssh-password-rejected.md) | **PASS** |

<!-- ponytail: manual Markdown status table for 10 core test cases; upgrade to JUnit XML output from scripts when integrating CI runner -->
