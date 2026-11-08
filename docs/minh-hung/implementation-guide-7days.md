# Hướng Dẫn Thực Thi Chi Tiết 7 Ngày, Sơ Đồ Trust Boundary & Kịch Bản Demo Ngày 7 (Minh Hùng)

**Phụ trách:** Minh Hùng  
**Nền tảng ảo hóa:** VMware Workstation Pro trên máy Host của Minh Hùng (kết nối liên site với máy Quan Bảo qua `Transit-B <-> Transit-A` bằng Tailscale).  
**Danh sách 6 VM thuộc phạm vi Minh Hùng:**
1. `Transit-B` (`172.20.20.6` — 1 vCPU / 768 MB RAM): Linux Transit VM chạy Tailscale subnet router & IP forwarding.
2. `Firewall-A` (`172.20.x.2`, VIP Gateway `172.20.x.1` — 1 vCPU / 1 GB RAM): Tường lửa chính chạy `nftables` + `keepalived`.
3. `Firewall-B` (`172.20.x.3` — 1 vCPU / 1 GB RAM): Tường lửa dự phòng HA / khôi phục sự cố.
4. `DB-Primary` (`172.20.40.11` — 2 vCPU / 1.5 GB RAM): PostgreSQL 16 Primary (Read-Write).
5. `DB-Replica` (`172.20.40.12` — 2 vCPU / 1.5 GB RAM): PostgreSQL 16 Hot Standby (Streaming Replication).
6. `Log-Monitor` (`172.20.50.10` — 1 vCPU / 1 GB RAM): Máy chủ thu thập `rsyslog` tập trung & quản trị MGMT.

> **Chiến lược quản lý RAM (Profile bật tuần tự):** Không cần bật đồng thời cả 11 VM của hai thành viên mọi lúc. Trong ngày thường chỉ bật các VM đúng theo mục tiêu từng ngày (~3.5 – 5.2 GB RAM trên máy Minh Hùng); bật thêm `Firewall-B` hoặc `DB-Replica` đúng kịch bản kiểm thử HA/Failover (Ngày 4, 5, 7). Luôn chụp snapshot sạch trước mỗi mốc quan trọng.

---

## Phần 1: Sơ Đồ Kiến Trúc & Ranh Giới Tin Cậy (Trust Boundary Diagram)

### 1.1. Sơ đồ Trust Boundary tổng thể

```text
====================================================================================================
 [TB-01: UNTRUSTED EXTERNAL ZONE — WAN-LAB 172.20.10.0/24]
   +----------------------------+
   | Test-Client (172.20.10.10) |  (Chỉ được phép gọi HTTPS/HTTP tới VIP 172.20.20.100:80,443;
   +-------------+--------------+   mọi nỗ lực quét DB/MGMT/Web IP trực tiếp bị DROP + LOG)
                 |
=================|======================== [RANH GIỚI TIN CẬY CHÍNH: STATEFUL FIREWALL] ============
                 v  (eth0: 172.20.10.1)
   +-----------------------------------------------------------------------------------+
   |                     CỤM TƯỜNG LỬA KIỂM SOÁT TRUNG TÂM (Minh Hùng)                 |
   |   [Firewall-A: 172.20.x.2 (Active)]  <== VRRP VIP .1 ==>  [Firewall-B: 172.20.x.3]|
   |   Policy: nftables deny-by-default | Anti-spoofing | Limited DNAT | Audit Logging |
   +------+--------------------+-----------------------+-----------------------+-------+
          | (eth1: .20.1)      | (eth2: .30.1)         | (eth3: .40.1)         | (eth4: .50.1)
          v                    v                       v                       v
==========|====================|=======================|=======================|====================
 [TB-02: SEMI-TRUSTED DMZ]   [TB-03: APP ZONE]      [TB-04: RESTRICTED DB]   [TB-05: ISOLATED MGMT]
      172.20.20.0/24          172.20.30.0/24            172.20.40.0/24           172.20.50.0/24
 +------------------------+  +----------------+    +-----------------------+ +---------------------+
 | VIP: 172.20.20.100     |  | (Vùng thiết kế |    | DB-Primary (.40.11)   | | Log-Monitor (.50.10)|
 | LB-A (.10) / LB-B (.11)|  |  mở rộng; Tuần |    |   |  Streaming WAL    | | - rsyslog UDP/TCP   |
 | Web-A (.21)/Web-B (.22)|  |  1 Web-A/B kiêm|--->|   v  TCP 5432         | |   port 514          |
 | (Quan Bảo vận hành)    |  |  App tối giản) |5432| DB-Replica (.40.12)   | | - Admin SSH Key-only|
 +-----------+------------+  +----------------+    +-----------------------+ +---------------------+
             |
             |  [TB-06: ENCRYPTED SITE-TO-SITE TRANSIT OVERLAY — KHÔNG BYPASS FIREWALL]
             |  +------------------------+     Tailscale WireGuard     +------------------------+
             +--| Transit-A (172.20.20.5)| <=========================> | Transit-B (172.20.20.6)|
                | (Máy Quan Bảo)         |   Chỉ advertise subnet lab  | (Máy Minh Hùng)        |
                +------------------------+   đã được duyệt trong ACL   +------------------------+
====================================================================================================
```

### 1.2. Bảng Phân Tích Các Ranh Giới Tin Cậy (Trust Boundaries)

| Mã TB | Ranh giới chuyển tiếp | Mức độ tin cậy | Cơ chế kiểm soát bắt buộc (Minh Hùng thực thi) |
| :--- | :--- | :--- | :--- |
| **TB-01** | `WAN-LAB` -> `Firewall` -> `DMZ VIP` | Untrusted -> Semi-Trusted | Anti-spoofing nguồn `172.20.10.0/24`; DNAT & Forward chỉ mở `TCP 80, 443` vào duy nhất `172.20.20.100` (`FW-ALLOW-WAN-VIP`); chặn thẳng Web thực/DB/MGMT (`FW-DENY-WAN-DIRECT`). |
| **TB-02** | `Transit-A` <-> `Transit-B` (Tailscale) | Encrypted Transit Tunnel | Tailscale chỉ chạy trên 2 Transit VM; tắt tính năng cài agent lên Web/DB để ngăn đường vòng (bypass) qua overlay network; Tailscale ACL khóa chặt subnet được phép advertise. |
| **TB-03** | `DMZ (Web/App)` -> `DATABASE` | Semi-Trusted -> Restricted | Firewall chỉ mở `TCP 5432` từ đúng IP `172.20.20.21, .22` tới `172.20.40.11, .12` (`FW-ALLOW-WEB-DB`); kết hợp `pg_hba.conf` `scram-sha-256` và user `app_user` không có quyền `DELETE/DROP`. |
| **TB-04** | `DB-Primary` <-> `DB-Replica` | Restricted Internal Sync | Chỉ mở `TCP 5432` hai chiều giữa `.40.11` và `.40.12` (`FW-ALLOW-DB-REPL`) dùng tài khoản riêng `repl_user` (`CONNECTION LIMIT 3`). |
| **TB-05** | `MANAGEMENT` -> Toàn bộ Linux VM | High-Trust Admin Plane | Chỉ dải `172.20.50.0/24` được kết nối `TCP 22` (`FW-ALLOW-MGMT-SSH`) với xác thực SSH `ed25519` key-only, tắt `PermitRootLogin` và `PasswordAuthentication`; luồng syslog một chiều về `172.20.50.10:514`. |

---

## Phần 2: Lộ Trình Thực Thi Chi Tiết 7 Ngày Của Minh Hùng

### Ngày 1 — Khởi tạo Baseline, VMware Host-Only Networks & Snapshot sạch
1. **Tạo 5 mạng Host-Only cô lập trên VMware Workstation** (tắt DHCP tự động của VMware trên các mạng dữ liệu để gán IP tĩnh chuẩn):
   - `WAN-LAB` (`172.20.10.0/24`), `DMZ` (`172.20.20.0/24`), `APP` (`172.20.30.0/24`), `DATABASE` (`172.20.40.0/24`), `MANAGEMENT` (`172.20.50.0/24`).
2. **Dựng 6 VM Debian 12 Minimal (không GUI)** theo đúng cấu hình vCPU/RAM:
   - Đặt hostname chuẩn: `transit-b`, `firewall-a`, `firewall-b`, `db-primary`, `db-replica`, `log-monitor`.
   - Đồng bộ múi giờ và NTP trên tất cả các máy: `sudo timedatectl set-timezone Asia/Ho_Chi_Minh`.
   - Cấu hình SSH key-only cho user quản trị, tắt đăng nhập mật khẩu và root SSH.
3. **Đầu ra & Kiểm tra cuối Ngày 1:**
   - Lưu thông số VM/VMnet vào `configs/vmware/minh-hung/`.
   - Tắt máy sạch và tạo snapshot `day-1-clean` trên cả 6 VM.

---

### Ngày 2 — Cấu hình `Transit-B`, Tailscale Subnet Routing & Phân vùng mạng
*(Profile VM bật: `Transit-B`, `Firewall-A`, `Log-Monitor`)*
1. **Bật định tuyến IP trên `Transit-B` (`172.20.20.6`) và `Firewall-A`:**
   ```bash
   echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-lab-forward.conf
   sudo sysctl --system
   ```
2. **Cài đặt và quảng bá subnet trên `Transit-B`:**
   ```bash
   sudo tailscale up --advertise-routes=172.20.20.0/24,172.20.40.0/24,172.20.50.0/24 --accept-routes
   ```
   - Phê duyệt route trên Tailscale Admin Console và áp dụng chính sách ACL trong `configs/tailscale/`.
   - Cấu hình static route trên `Firewall-A` trỏ các dải phía Site A của Quan Bảo qua `Transit-B` (`172.20.20.6`) khi cần đi liên site.
3. **Đầu ra & Bằng chứng Ngày 2:**
   - Chạy `ROLE=transit ./scripts/minh-hung/verify-routes-and-firewall.sh`.
   - Thu thập bằng chứng `TC-MH-RT-01` và `TC-MH-RT-02` bằng `collect-evidence.sh`.

---

### Ngày 3 — Triển khai Tường lửa `nftables` Deny-by-Default, NAT & Logging
*(Profile VM bật: `Transit-B`, `Firewall-A`, `Log-Monitor`)*
1. **Nạp cấu hình tường lửa chuẩn lên `Firewall-A`:**
   ```bash
   sudo cp configs/firewall/nftables-firewall.conf /etc/nftables.conf
   sudo nft -c -f /etc/nftables.conf          # Kiểm tra cú pháp dry-run bắt buộc
   sudo systemctl enable --now nftables
   sudo systemctl reload nftables
   ```
2. **Cấu hình VIP Gateway (`172.20.x.1`) trên 5 interface `eth0..eth4`** (qua `keepalived` hoặc tĩnh ở bước đầu) để làm default gateway cho toàn bộ các VLAN.
3. **Đầu ra & Bằng chứng Ngày 3:**
   - Đối chiếu với `lab/firewall/firewall-rule-matrix.md`.
   - Phối hợp với Quan Bảo thử từ `Test-Client` (`172.20.10.10`) vào VIP `172.20.20.100` (thành công) và vào thẳng Web/DB/MGMT (bị chặn + sinh log `FW-DENY-WAN-DIRECT:`).
   - Lưu bằng chứng `TC-MH-FW-01` và `TC-MH-FW-02`.

---

### Ngày 4 — PostgreSQL Streaming Replication, Least Privilege & Syslog Tập Trung
*(Profile VM bật: `Transit-B`, `Firewall-A`, `DB-Primary`, `DB-Replica`, `Log-Monitor`)*
1. **Triển khai `rsyslog` tập trung trên `Log-Monitor` (`172.20.50.10`):**
   ```bash
   sudo cp lab/monitoring/rsyslog-central.conf /etc/rsyslog.d/10-rsyslog-central.conf
   sudo systemctl restart rsyslog
   ./lab/monitoring/monitoring-healthcheck.sh
   ```
   - Trên `Firewall-A/B`, `DB-Primary/Replica`, cấu hình chuyển tiếp syslog về `@172.20.50.10:514`.
2. **Triển khai PostgreSQL 16 trên `DB-Primary` (`172.20.40.11`) & `DB-Replica` (`172.20.40.12`):**
   - Thực hiện theo `lab/database/postgresql-replication-setup.md`.
   - Chạy `lab/database/init-least-privilege.sql` (đặt mật khẩu runtime cho `repl_user` và `app_user`, không lưu mật khẩu vào Git).
   - Tạo slot `replica_slot_1` và chạy `pg_basebackup` sang `172.20.40.12`.
3. **Đầu ra & Bằng chứng Ngày 4:**
   - Chạy `./scripts/minh-hung/verify-db-replication.sh`.
   - Thu thập bằng chứng `TC-MH-DB-01` (đồng bộ dữ liệu) và `TC-MH-DB-02` (`app_user` bị chặn `DELETE/DROP`).
   - Chụp snapshot `day-4-cluster-ready`.

---

### Ngày 5 — Diễn tập Failover & Recovery (DB Promote & Firewall-A/B Failover)
*(Profile VM bật theo pha: Pha 1 bật cụm DB; Pha 2 bật `Firewall-A` + `Firewall-B`)*
1. **Pha 1 — DB Failover & Re-join (theo `lab/database/promote-and-recovery-runbook.md`):**
   - Ghi mốc thời gian, dừng `postgresql` trên `DB-Primary` (`172.20.40.11`).
   - Chạy `SELECT pg_promote(wait => true, wait_seconds => 30);` trên `DB-Replica` (`172.20.40.12`).
   - Phối hợp Quan Bảo trỏ ứng dụng Web sang `172.20.40.12`, xác nhận ghi mới thành công.
   - Đưa `172.20.40.11` gia nhập lại làm Standby bằng `pg_basebackup`.
2. **Pha 2 — Firewall-A Failure, Switchover sang Firewall-B & Restore Backup (theo `lab/firewall/failover-and-recovery-runbook.md`):**
   - Sao lưu ruleset `Firewall-A`, đồng bộ cấu hình sang `Firewall-B` (`172.20.50.3`).
   - Hạ `Firewall-A` để `Firewall-B` nắm giữ VIP `.1`; kiểm chứng lưu lượng WAN -> VIP vẫn sống và WAN -> DB vẫn bị khóa.
   - Khôi phục `Firewall-A` từ file backup và thực hiện failback.
3. **Đầu ra & Bằng chứng Ngày 5:**
   - Thu thập biên bản `TC-MH-FO-01`, `TC-MH-FO-02` và `TC-MH-FW-REC-01` kèm số đo RTO thực tế.

---

### Ngày 6 — Kiểm Thử Bảo Mật Chéo (Negative Security Audit) & Tinh Chỉnh Policy
*(Profile VM bật: `Transit-B`, `Firewall-A`, `DB-Primary`, `Log-Monitor`)*
1. **Phối hợp cùng Quan Bảo chạy đợt tấn công mô phỏng từ `Test-Client` (`172.20.10.10`):**
   - Quét cổng giới hạn vào VIP, Web IP thực, DB subnet và MGMT subnet.
   - Thử kết nối SSH bằng mật khẩu, thử giả mạo IP nguồn (anti-spoofing).
2. **Rà soát toàn diện phía Minh Hùng:**
   - Kiểm tra đối chiếu thời gian thực trên `Log-Monitor` (`/var/log/central/`), bảng định tuyến, Tailscale ACL và quyền PostgreSQL.
   - Khắc phục ngay mọi điểm lệch chính sách trong phạm vi ownership của Minh Hùng và chạy lại script kiểm chứng.
3. **Đầu ra Ngày 6:**
   - Cập nhật đầy đủ cột **Actual Result** và trạng thái `PASS` trong `lab/testing/minh-hung/test-cases-minh-hung.md`.

---

### Ngày 7 — Rà Soát Bảo Mật Git, Đồng Bộ Nghiệm Thu & Trình Diễn Live Demo
1. **Kiểm tra an toàn kho mã nguồn trước giờ bảo vệ:**
   - Quét chắc chắn không tồn tại password, Tailscale token hay private key trong toàn bộ `configs/`, `scripts/`, `evidence/`, `docs/`.
   - Đối chiếu 100% số liệu IP, port, log prefix giữa `README.md`, `lab-v2.html`, `firewall-rule-matrix.md` và các runbook.
2. **Bật sẵn Profile Trình Diễn (Demo Profile)** và kiểm tra sức khỏe toàn tuyến bằng 2 script:
   - `./scripts/minh-hung/verify-routes-and-firewall.sh`
   - `./scripts/minh-hung/verify-db-replication.sh`

---

## Phần 3: Kịch Bản Trình Diễn Live Demo Ngày 7 (Thời lượng ~15 Phút)

> **Cấu hình VM bật sẵn trước giờ Demo:**
> - **Máy Quan Bảo:** `Transit-A`, `LB-A`, `Web-A`, `Web-B`, `Test-Client`.
> - **Máy Minh Hùng:** `Transit-B`, `Firewall-A`, `Firewall-B` (chờ sẵn hoặc bật ở Phút 11), `DB-Primary`, `DB-Replica`, `Log-Monitor`.

| Thời lượng | Bước Demo | Người thao tác chính | Lệnh trình diễn trực tiếp | Điểm nhấn chứng minh |
| :---: | :--- | :--- | :--- | :--- |
| **Phút 00–02** | **1. Kiến trúc & Trust Boundary** | Minh Hùng & Quan Bảo | Trên `Transit-B`: `tailscale status`<br>Trên `DB-Primary`: `ip -br addr` | Chứng minh 2 site nối qua Transit VM; Web/DB hoàn toàn không cài Tailscale nên không thể bypass Firewall. |
| **Phút 02–05** | **2. Luồng hợp lệ & Chặn truy cập trái phép + Audit Log** | Quan Bảo bắn lệnh từ `Test-Client`; Minh Hùng mở màn hình `Log-Monitor` | `Test-Client`:<br>`curl -k https://172.20.20.100`<br>`nc -zv -w 2 172.20.20.21 80`<br>`nc -zv -w 2 172.20.40.11 5432`<br>`Log-Monitor`:<br>`tail -f /var/log/central/firewall-a/kernel.log` | Truy cập qua VIP thành công (luân phiên Web-A/Web-B); truy cập thẳng Web-A và DB lập tức bị chặn và hiện log `FW-DENY-WAN-DIRECT:` theo thời gian thực. |
| **Phút 05–08** | **3. Web Failover + DB Replication & Least Privilege** | Quan Bảo dừng `Web-A`; Minh Hùng kiểm tra DB | `./scripts/minh-hung/verify-db-replication.sh`<br>Thử `DELETE FROM request_audit_logs;` bằng `app_user` | Web-A dừng nhưng VIP vẫn trả kết quả từ Web-B; dữ liệu request mới đồng bộ tức thời sang `DB-Replica`; `app_user` bị chặn quyền xóa log (`permission denied`). |
| **Phút 08–11** | **4. Sự cố sập DB-Primary & Promote DB-Replica** | Minh Hùng | Trên `DB-Primary`: `sudo systemctl stop postgresql`<br>Trên `DB-Replica`: `sudo -u postgres psql -c "SELECT pg_promote();"`<br>Kiểm tra `pg_is_in_recovery()` -> `f` | Đánh sập Primary trực tiếp; promote Replica lên Read-Write trong < 30 giây; ứng dụng tiếp tục ghi nhận giao dịch không mất dữ liệu. |
| **Phút 11–14** | **5. Sự cố Firewall-A & Khôi phục trên Firewall-B** | Minh Hùng | Trên `Firewall-A`: `sudo systemctl stop keepalived`<br>Trên `Firewall-B`: `ip -br addr show` & `sudo nft list ruleset \| head -n 25` | `Firewall-B` tiếp quản Gateway VIP `.1`; chính sách bảo mật giữ nguyên vẹn (VIP vẫn mở, DB vẫn khóa chặt). |
| **Phút 14–15** | **6. Tổng kết Biên bản Evidence** | Minh Hùng & Quan Bảo | Mở thư mục `evidence/minh-hung/` & `test-cases-minh-hung.md` | Trình bày bộ biên bản chuẩn hóa `YYYYMMDD-minh-hung-*`, khớp timestamp trên cả 4 tầng (Firewall, LB, Web, DB). |

<!-- ponytail: manual step-by-step live demo runbook for 2 operators; upgrade to tmuxinator multi-pane script if running solo demos -->
