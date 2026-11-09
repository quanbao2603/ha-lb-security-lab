# Kịch bản kiểm thử chung Site A – Site B (Runbook + chụp evidence)

> **Người thực hiện chính:** Quan Bảo (thao tác từ Windows của Bảo).
> **Người hỗ trợ:** Minh Hùng (bật VM Site B, mở rule tạm, xác nhận policy).
> **Ngày lập:** 2026-11-10. **Trạng thái:** đường truy cập đã xác minh sống (xem mục 1.2).
> **Phạm vi:** phần tích hợp chung — KHÔNG làm lại các test riêng Site A đã có evidence.

---

## 0. Quy ước chung

### 0.1 Ownership

- Bảo không sửa file/thư mục ownership của Hùng (`lab/firewall/`, `lab/database/`, `lab/monitoring/`, `configs/tailscale/`, `…/minh-hung/`).
- Mọi thay đổi policy/firewall Site B phải do Hùng thực hiện hoặc Hùng đồng ý bằng tin nhắn.
- File chung (`README.md`, `lab-v2.html`, `lab/testing/acceptance-matrix.md`) chỉ cập nhật sau khi hai bên đối chiếu.

### 0.2 Quy tắc chụp ảnh

- Công cụ: `Win + Shift + S` (Snipping Tool) hoặc chụp cửa sổ terminal.
- Mỗi khung hình phải thấy: **prompt/hostname nơi chạy lệnh + dòng lệnh + kết quả**. Windows Terminal tự hiện tab title theo host SSH — giữ nguyên tab title trong ảnh.
- Ảnh đi cặp (client + log) phải chụp trong cùng cửa sổ thời gian để đối chiếu timestamp.
- **Không chụp lúc gõ mật khẩu thật** (sudo, mật khẩu SSH). Mật khẩu demo `DemoPass123!` đã công khai trong docs repo nên chấp nhận được, nhưng không đưa secret thật vào ảnh.
- Lưu ảnh vào `evidence/quan-bao/images/` với tên `20261110-quan-bao-joint-<slug>.png` (bảng đầy đủ ở Phụ lục A).
- Ghi mốc thời gian bằng `date -Is` (trên VM) hoặc `Get-Date -Format o` (Windows PowerShell) trước/sau các bước failover.

### 0.3 Git

- Không commit/push khi chưa được Bảo duyệt. Bảo tự push.
- Commit message ngắn 1–2 dòng, ví dụ: `evidence(quan-bao): add joint Site A-B integration test screenshots`.

---

## 1. Chuẩn bị

### 1.1 Danh sách VM phải bật

| Bên | VM | Ai bật | Ghi chú |
|---|---|---|---|
| Site A | Transit-A, LB-A, Web-A, Web-B, Test-Client | Bảo | Test-Client chỉ cần nếu bắn negative từ WAN client |
| Site B | Transit-B, Firewall-A, DB-Primary, Log-Monitor | Hùng | Bật trước batch 1 |
| Site B | DB-Replica | Hùng | Bật trước batch 2 (mặc định tắt) |
| Site B | Firewall-B | Hùng | Bật trước batch 3 (mặc định tắt) |

Nhắn Hùng trước: *"Anh bật giúp em DB-Replica với Firewall-B khi em xong batch 1 nhé."*

### 1.2 Đường truy cập SSH (đã xác minh từ Windows của Bảo)

Key `qoder-local` của Bảo đã được Hùng add vào `authorized_keys` của `ops` trên toàn bộ VM Site B.

| Đích | Lệnh từ Windows | Ghi chú |
|---|---|---|
| Transit-B | `ssh ops@172.20.20.6` | Trực tiếp, đã test OK |
| Log-Monitor | `ssh -J ops@172.20.20.6 ops@172.20.50.10` | Hùng mở rule tạm `[FW-ALLOW-SITE-A-JUMP:]` |
| Firewall-A | `ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.2` | Nhảy kép, source cuối thuộc MGMT |
| Firewall-B | `ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.3` | Chỉ khi Firewall-B bật |
| DB-Primary | `ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.40.11` | |
| DB-Replica | `ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.40.12` | Chỉ khi DB-Replica bật |
| VM Site A | `ssh quanbao2603@172.20.21.5` (Transit-A)… | Dùng mật khẩu/key thường dùng của Bảo; key `qoder-local` CHƯA được authorize trên Site A |

Quy tắc zero-trust TB-05: SSH vào Firewall/DB chỉ接受 source dải MGMT `172.20.50.0/24`. Vì vậy **không** SSH thẳng từ Windows vào `50.2`/`40.x` — bị DROP đúng thiết kế (dùng làm negative test).

**Việc cần Hùng làm trước batch 3:** đồng bộ rule tạm `[FW-ALLOW-SITE-A-JUMP:]` sang Firewall-B, nếu không trong lúc failover sẽ không nhảy kép vào trong được. Sau khi kết thúc toàn bộ kịch bản, Hùng gỡ rule tạm trên cả hai firewall.

### 1.3 Khoảng trống tích hợp đã biết (không phải lỗi để sửa)

- `VIP 172.20.20.100` (DMZ Site B) **chưa có service web phía sau** — evidence của Hùng cũng ghi `[WARN] Không kết nối được VIP 172.20.20.100:80`. KHÔNG dùng làm positive test. Positive web dùng VIP Site A `172.20.21.100` (đã có evidence riêng). Ghi nhận vào acceptance matrix là hạng mục tích hợp còn mở.
- `172.20.20.21/22` (Web theo spec gốc) không tồn tại trong triển khai thực tế — bỏ qua các probe tới IP này.

### 1.4 [CHỤP ẢNH C-01] Transit-A nhận route Site B

Chạy trên **Transit-A** (Bảo tự đăng nhập bằng tài khoản thường dùng, vì cần sudo):

```bash
sudo tailscale up --accept-routes --advertise-routes=172.20.21.0/24
ip route show 172.20.40.0/24
ping -c 3 172.20.40.11
```

Kỳ vọng: route `172.20.40.0/24` hiện qua `tailscale0`; ping `0% packet loss` (Hùng đã cho ICMP qua Firewall-A).

**Khung hình:** thấy cả lệnh `ip route` + kết quả ping 3 gói thành công trên cùng cửa sổ.
**Tên file:** `20261110-quan-bao-joint-transit-a-accept-routes.png`
**Nếu lệch:** route không hiện → kiểm tra `tailscale status` trên Transit-A; ping mất gói → nhờ Hùng xem rule ICMP trên Firewall-A.

---

## 2. Batch 1 — Kết nối chéo, firewall policy, negative test

### J-01 — Đường quản trị chéo site từ Windows

**Chạy trên Windows (CMD/PowerShell):**

```cmd
ssh -J ops@172.20.20.6 ops@172.20.50.10 hostname
```

Kỳ vọng: `log-monitor`, exit 0.

**[CHỤP ẢNH J-01]** — khung hình thấy lệnh + kết quả `log-monitor`.
**Tên file:** `20261110-quan-bao-joint-ssh-jump-log-monitor.png`
**Nếu lệch:** `Permission denied (publickey)` → key chưa add hoặc sai user; timeout → VM tắt/route thiếu; xem bảng troubleshooting mục 6.

### J-02 — Log rule tạm trên Firewall-A

**Chạy trên Windows:**

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.2 "sudo journalctl -k --since '10 minutes ago' --no-pager | grep FW-ALLOW-SITE-A-JUMP | tail -5"
```

Kỳ vọng: các dòng `[FW-ALLOW-SITE-A-JUMP:]` khớp thời điểm J-01.

**[CHỤP ẢNH J-02]** — thấy prefix log + timestamp.
**Tên file:** `20261110-quan-bao-joint-fw-allow-site-a-jump-log.png`
**Nếu lệch:** không có dòng nào → Hùng chưa nạp rule tạm hoặc rule đặt sau rule drop; nhờ Hùng kiểm tra vị trí rule trong chain forward.

### J-03 — Route không bypass firewall trên Transit-B

```cmd
ssh ops@172.20.20.6 "ip route show 172.20.40.0/24; ip route show 172.20.50.0/24; cat /proc/sys/net/ipv4/ip_forward"
```

Kỳ vọng: hai route `via 172.20.20.1 dev eth0`; `ip_forward = 1`.

**[CHỤP ẢNH J-03]** — thấy cả hai route đi qua gateway firewall.
**Tên file:** `20261110-quan-bao-joint-transit-b-routes.png`
**Ý nghĩa chứng minh:** mọi lưu lượng vào DB/MGMT bắt buộc qua Firewall-A, không thể bypass.

### J-04 — Firewall policy + VIP trên Firewall-A

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.2 "sudo systemctl is-active nftables keepalived; sudo nft list ruleset | grep -E 'policy drop|FW-' | head -25; ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'"
```

Kỳ vọng: `active` (cả hai service); `policy drop`; đủ prefix `FW-ALLOW-WAN-VIP`, `FW-DENY-WAN-DIRECT`, `FW-DENY-WAN-DB`, `FW-ALLOW-MGMT-SSH`, `FW-DEFAULT-DENY`…; các IP gateway `.1` nằm trên Firewall-A.

**[CHỤP ẢNH J-04]** — một khung thấy service active + policy drop + VIP `.1`.
**Tên file:** `20261110-quan-bao-joint-fw-a-policy-vip.png`

### J-05 — Negative test từ Windows

**PowerShell:**

```powershell
Test-NetConnection 172.20.40.11 -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
```

Kỳ vọng: `False` (DB không thể chạm từ ngoài MGMT).

**CMD (thử SSH password — nhập một mật khẩu sai bất kỳ khi được hỏi):**

```cmd
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no ops@172.20.20.6
```

Kỳ vọng: `Permission denied (publickey)` hoặc `Permission denied (password)` — hardening key-only hoạt động.

**[CHỤP ẢNH J-05]** — chụp chung một cửa sổ: `False` + dòng Permission denied. Không chụp lúc gõ mật khẩu.
**Tên file:** `20261110-quan-bao-joint-negative-client.png`
**Ghi nhớ thời điểm** để đối chiếu J-06.

### J-06 — Log deny trên Firewall-A khớp J-05

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.2 "sudo journalctl -k --since '2 minutes ago' --no-pager | grep -E 'FW-DENY|FW-DEFAULT' | tail -5"
```

Kỳ vọng: dòng deny tới `172.20.40.11:5432` (hoặc default deny) khớp thời điểm J-05.

**[CHỤP ẢNH J-06]** — thấy prefix deny + timestamp + IP đích.
**Tên file:** `20261110-quan-bao-joint-fw-deny-log.png`
**Nếu lệch:** không có log → probe bị chặn ở tầng Tailscale ACL trước firewall (chấp nhận được, ghi rõ tầng chặn vào evidence); muốn log firewall thì bắn từ Test-Client sau khi Transit-A đã accept-routes (C-01).

**Kết thúc batch 1:** gửi Hùng xác nhận đã bật DB-Replica + Firewall-B và đồng bộ rule tạm sang Firewall-B trước khi sang batch 2/3.

---

## 3. Batch 2 — Database replication, least privilege, failover

### J-07 — Replication đồng bộ Primary ↔ Replica

Mở **hai cửa sổ terminal** trên Windows.

Cửa sổ 1 — DB-Primary:

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.40.11
```

```bash
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
sudo -u postgres psql -d ha_lab_db -c "SELECT id,node_name,status FROM health_checks ORDER BY id DESC LIMIT 5;"
```

Cửa sổ 2 — DB-Replica:

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.40.12
```

```bash
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
sudo -u postgres psql -d ha_lab_db -c "SELECT id,node_name,status FROM health_checks ORDER BY id DESC LIMIT 5;"
```

Kỳ vọng: primary `f`, replica `t`; **hai bảng 5 dòng giống hệt nhau**.

**[CHỤP ẢNH J-07]** — chụp màn hình chứa CẢ HAI cửa sổ cạnh nhau, thấy `f`/`t` và dữ liệu trùng khớp.
**Tên file:** `20261110-quan-bao-joint-db-replication-sync.png`
**Nếu lệch:** replica `No route to host` → Hùng chưa bật DB-Replica; dữ liệu lệch → chạy lại sau vài giây (WAL replay), nếu vẫn lệch kiểm tra `pg_stat_replication` trên primary.

### J-08 — Least privilege: app_user được ghi, không được xóa

Trên **DB-Primary** (cửa sổ 1 của J-07):

```bash
sudo -u postgres psql -c "ALTER USER app_user PASSWORD 'DemoPass123!';"
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c "INSERT INTO health_checks(node_name,status) VALUES ('DEMO-JOINT','OK') RETURNING id;"
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c "UPDATE health_checks SET status='OK' WHERE node_name='DEMO-JOINT';"
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c "DELETE FROM health_checks WHERE node_name='DEMO-JOINT';"
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c "DROP TABLE health_checks;"
```

Kỳ vọng: INSERT trả `id` (thành công); UPDATE thành công; DELETE báo `ERROR: permission denied for table health_checks`; DROP báo `ERROR: must be owner of table health_checks`.

**[CHỤP ẢNH J-08]** — thấy INSERT OK + DELETE/DROP bị denied trong một khung.
**Tên file:** `20261110-quan-bao-joint-db-least-privilege.png`

### J-09 — DB failover: đánh sập Primary, promote Replica (đo RTO)

**Bước 1 — Windows:** ghi T0:

```powershell
Get-Date -Format o
```

**Bước 2 — DB-Primary:**

```bash
sudo systemctl stop postgresql
systemctl is-active postgresql
```

Kỳ vọng: `inactive`.

**Bước 3 — DB-Replica:** kiểm tra WAL rồi promote:

```bash
sudo -u postgres psql -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
sudo -u postgres psql -c "SELECT pg_promote(wait => true, wait_seconds => 30);"
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
```

Kỳ vọng: `pg_promote` trả `t`; `pg_is_in_recovery()` = `f` (đã thành Primary Read-Write).

**Bước 4 — DB-Replica:** ghi thử bằng app_user:

```bash
PGPASSWORD='DemoPass123!' psql -h 172.20.40.12 -U app_user -d ha_lab_db -c "INSERT INTO health_checks(node_name,status) VALUES ('db-replica-promoted','OK');"
```

Kỳ vọng: INSERT thành công.

**Bước 5 — Windows:** ghi T1, tính RTO = T1 − T0 (kỳ vọng < 30 giây cho thao tác promote):

```powershell
Get-Date -Format o
```

**[CHỤP ẢNH J-09a]** — cửa sổ primary `inactive` + cửa sổ replica `pg_promote = t`.
**Tên file:** `20261110-quan-bao-joint-db-failover-promote.png`
**[CHỤP ẢNH J-09b]** — replica `f` + INSERT OK + T1.
**Tên file:** `20261110-quan-bao-joint-db-failover-verify.png`
**Nếu lệch:** promote trả `f` → replica chưa nhận đủ WAL hoặc PostgreSQL < 12 (dùng `pg_ctl promote` theo runbook); INSERT lỗi kết nối → kiểm tra `pg_hba.conf` cho app_user từ MGMT.

### J-10 — Rejoin: đưa Primary cũ về làm Standby

> **CẢNH BÁO:** lệnh `rm -rf` bên dưới chỉ chạy trên **VM lab DB-Primary cũ** và **chỉ sau khi** DB-Replica đã promote thành công và ghi thử OK (dữ liệu an toàn trên primary mới). Làm đúng thứ tự, không chạy ngược. Đây là quy trình chuẩn trong `lab/database/promote-and-recovery-runbook.md`.

Trên **DB-Primary cũ (40.11):**

```bash
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/16/main/*
sudo -u postgres pg_basebackup -h 172.20.40.12 -p 5432 -U repl_user -D /var/lib/postgresql/16/main -Fp -Xs -P -R
sudo systemctl start postgresql
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
```

Kỳ vọng: `pg_basebackup` hoàn tất; `pg_is_in_recovery()` = `t` (node cũ thành standby của primary mới `.12`).

**[CHỤP ẢNH J-10]** — thấy basebackup hoàn tất + `t`.
**Tên file:** `20261110-quan-bao-joint-db-rejoin-standby.png`
**Nếu lệch:** `pg_basebackup` hỏi mật khẩu → dùng mật khẩu replication Hùng cấp (không đoán); lỗi version PostgreSQL khác 16 → chỉnh đường dẫn `/var/lib/postgresql/<version>/main` theo `ls /var/lib/postgresql/`.

---

## 4. Batch 3 — Firewall failover & failback

**Điều kiện tiên quyết:** Hùng đã bật Firewall-B và đồng bộ rule tạm `[FW-ALLOW-SITE-A-JUMP:]` sang Firewall-B.

### J-11 — Failover: Firewall-A ngã, Firewall-B tiếp quản VIP .1

**Bước 1 — Windows:** ghi T0 (`Get-Date -Format o`).

**Bước 2 — Firewall-A:**

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.2 "sudo systemctl stop keepalived; systemctl is-active keepalived"
```

Kỳ vọng: `inactive`.

**Bước 3 — Firewall-B:**

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.3 "ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'; sudo systemctl is-active nftables; sudo nft list ruleset | grep -c 'FW-'"
```

Kỳ vọng: các gateway `.1` xuất hiện trên Firewall-B; `nftables active`; số rule `FW-` > 0 (policy đầy đủ, không hở).

**Bước 4 — Windows:** negative vẫn phải chặn khi đi qua Firewall-B:

```powershell
Test-NetConnection 172.20.40.11 -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
```

Kỳ vọng: `False`. Ghi T1.

**[CHỤP ẢNH J-11a]** — cửa sổ Firewall-B thấy VIP `.1` + nftables active.
**Tên file:** `20261110-quan-bao-joint-fw-failover-fwb-vip.png`
**[CHỤP ẢNH J-11b]** — Windows `False` + T1.
**Tên file:** `20261110-quan-bao-joint-fw-failover-client-negative.png`
**Nếu lệch:** nhảy kép vào fw-b thất bại → rule tạm chưa có trên Firewall-B (nhờ Hùng thêm); VIP không sang → xem phương án thủ công mục 4–5 của `lab/firewall/failover-and-recovery-runbook.md` (ip addr add/del + arping) và nhờ Hùng thao tác.

### J-12 — Failback: trả VIP về Firewall-A

**Firewall-A:**

```cmd
ssh -J ops@172.20.20.6,ops@172.20.50.10 ops@172.20.50.2 "sudo systemctl start keepalived; sleep 3; ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'"
```

Kỳ vọng: `.1` quay lại Firewall-A (keepalived priority cao hơn/preempt). Nếu không quay lại: trên Firewall-B `sudo systemctl stop keepalived` rồi kiểm tra lại Firewall-A.

**Windows:** negative lần cuối vẫn `False` (Test-NetConnection như J-11 bước 4).

**[CHỤP ẢNH J-12]** — Firewall-A giữ lại `.1` + kết quả negative.
**Tên file:** `20261110-quan-bao-joint-fw-failback.png`

---

## 5. Batch 4 — Log tập trung, lưu evidence, đối chiếu nghiệm thu

### J-13 — Central syslog trên Log-Monitor

```cmd
ssh -J ops@172.20.20.6 ops@172.20.50.10 "ls -lh /var/log/central/; sudo tail -n 30 /var/log/central/firewall-a/kernel.log"
```

Kỳ vọng: thư mục central có log firewall-a; các dòng `FW-DENY`/`FW-ALLOW-SITE-A-JUMP` timestamp khớp các bước J-05/J-06/J-11.

**[CHỤP ẢNH J-13]** — thấy danh sách thư mục + dòng log khớp thời điểm test.
**Tên file:** `20261110-quan-bao-joint-central-syslog.png`
**Nếu lệch:** thư mục trống → kiểm tra rsyslog trên Log-Monitor (`sudo systemctl is-active rsyslog`, port 514) và chiều gửi log từ Firewall-A.

### 5.1 Lưu ảnh và biên bản

1. Copy toàn bộ ảnh C-01, J-01…J-13 vào `evidence/quan-bao/images/` theo tên ở Phụ lục A (không ghi đè ảnh cũ).
2. Tạo biên bản `evidence/quan-bao/20261110-quan-bao-joint-integration.md` theo template Phụ lục B, liệt kê từng test: lệnh, expected, actual, PASS/FAIL, link ảnh.
3. Đối chiếu với Hùng rồi mới tạo/cập nhật file chung `lab/testing/acceptance-matrix.md` (draft ở Phụ lục C).

### 5.2 Dọn dẹp sau kịch bản

- Hùng gỡ rule tạm `[FW-ALLOW-SITE-A-JUMP:]` trên cả Firewall-A và Firewall-B.
- Hùng tắt Firewall-B/DB-Replica nếu cần giải phóng RAM (sau khi đã failback/rejoin).
- Ghi chú trạng thái cuối: DB primary hiện tại là `172.20.40.12`; node `.11` là standby.
- Không commit khi chưa duyệt; Bảo tự push với message 1–2 dòng.

---

## 6. Troubleshooting nhanh

| Triệu chứng | Nguyên nhân thường gặp | Xử lý |
|---|---|---|
| `Permission denied (publickey)` | Key chưa add / sai user | Hùng chạy lại vòng lặp add key; kiểm tra `grep qoder-local ~/.ssh/authorized_keys` trên VM |
| `Connection timed out` | VM tắt/suspend, thiếu route, ACL chặn | Hùng kiểm tra VMware + `tailscale status`; Windows `route print \| findstr 172.20` |
| `No route to host` | VM standby chưa bật (FW-B, DB-Replica) | Hùng bật VM |
| SSH thẳng Windows → 50.2/40.x bị chặn | Đúng thiết kế TB-05 | Dùng nhảy kép qua Log-Monitor; giữ làm negative evidence |
| Nhảy kép chết trong lúc firewall failover | Rule tạm thiếu trên Firewall-B | Hùng đồng bộ rule tạm sang FW-B |
| `sudo` hỏi mật khẩu trong lệnh one-liner | Lệnh chạy không tương tác | Đăng nhập phiên SSH riêng rồi chạy lệnh sudo trong phiên đó |
| VIP không chuyển khi stop keepalived | Keepalived chưa quản lý VIP trên node đó | Dùng quy trình thủ công ip addr + arping trong firewall runbook, nhờ Hùng thao tác |

---

## Phụ lục A — Bảng tên ảnh evidence

| Mã | Tên file trong `evidence/quan-bao/images/` |
|---|---|
| C-01 | `20261110-quan-bao-joint-transit-a-accept-routes.png` |
| J-01 | `20261110-quan-bao-joint-ssh-jump-log-monitor.png` |
| J-02 | `20261110-quan-bao-joint-fw-allow-site-a-jump-log.png` |
| J-03 | `20261110-quan-bao-joint-transit-b-routes.png` |
| J-04 | `20261110-quan-bao-joint-fw-a-policy-vip.png` |
| J-05 | `20261110-quan-bao-joint-negative-client.png` |
| J-06 | `20261110-quan-bao-joint-fw-deny-log.png` |
| J-07 | `20261110-quan-bao-joint-db-replication-sync.png` |
| J-08 | `20261110-quan-bao-joint-db-least-privilege.png` |
| J-09a | `20261110-quan-bao-joint-db-failover-promote.png` |
| J-09b | `20261110-quan-bao-joint-db-failover-verify.png` |
| J-10 | `20261110-quan-bao-joint-db-rejoin-standby.png` |
| J-11a | `20261110-quan-bao-joint-fw-failover-fwb-vip.png` |
| J-11b | `20261110-quan-bao-joint-fw-failover-client-negative.png` |
| J-12 | `20261110-quan-bao-joint-fw-failback.png` |
| J-13 | `20261110-quan-bao-joint-central-syslog.png` |

## Phụ lục B — Template biên bản evidence

```markdown
# Biên bản kiểm thử: 20261110-quan-bao-joint-integration

| Trường | Giá trị |
|---|---|
| Người thực hiện | Quan Bảo (thao tác từ Windows) |
| Người xác nhận Site B | Minh Hùng |
| Thời gian bắt đầu / kết thúc | <ISO timestamp> |
| Phạm vi | Kiểm thử tích hợp chung Site A – Site B |

| Mã | Lệnh chính | Expected | Actual | Kết quả | Evidence |
|---|---|---|---|---|---|
| J-01 | ssh -J … hostname | log-monitor | <điền> | PASS/FAIL | images/20261110-quan-bao-joint-ssh-jump-log-monitor.png |
| … | … | … | … | … | … |

## Khoảng trống tích hợp còn mở
- VIP 172.20.20.100 chưa có web service phía sau (thống nhất hướng xử lý với Hùng).
```

## Phụ lục C — Draft acceptance matrix chung (chỉ tạo file chung sau khi đối chiếu)

| Nhóm | Test | Expected | Owner | Evidence |
|---|---|---|---|---|
| Transit | Route chéo Site A ↔ Site B | ping/curl/SSH đúng phạm vi | Bảo + Hùng | C-01, J-01 |
| Transit | Không bypass firewall | route 40/50 via 20.1 | Hùng | J-03 |
| Firewall | Deny-by-default + log | policy drop, log deny khớp | Hùng | J-04, J-05, J-06 |
| Firewall | Failover A→B + failback | VIP .1 chuyển, policy giữ nguyên | Hùng | J-11, J-12 |
| DB | Replication | primary f / replica t, dữ liệu khớp | Hùng | J-07 |
| DB | Least privilege | INSERT OK / DELETE denied | Hùng | J-08 |
| DB | Failover + rejoin | promote < 30s, node cũ thành standby | Hùng | J-09, J-10 |
| Monitoring | Log tập trung khớp timestamp | central log đủ 4 tầng | Hùng | J-13 |
| Web/LB | VIP Site A + round-robin + web failover | đã PASS ở phần riêng Site A | Bảo | evidence Site A 20261108/20261109 |
| Tích hợp mở | WAN → VIP Site B (20.100) | chưa triển khai web sau VIP | Cả hai | ghi nhận gap, không tính FAIL |