# Kịch bản toàn diện Site B (phần Minh Hùng)

Tài liệu này tổng hợp kịch bản khởi động, kiểm thử, đối soát log và thu evidence cho toàn bộ
hệ thống Site B: Transit-B, Firewall-A/B, DB-Primary/Replica và Log-Monitor.
Mọi lệnh dưới đây đã được kiểm chứng trong phiên tích hợp liên site.

Các mốc cần chụp ảnh minh chứng được đánh dấu:

```text
[CHỤP ẢNH SB-xx]
```

kèm mô tả nội dung phải thấy trong khung hình và tên file đề xuất.

## 0. Quy tắc chụp ảnh evidence

1. Chụp **toàn bộ cửa sổ terminal**, thấy rõ prompt hostname (ví dụ `ops@fw-a:~$`) để chứng minh đúng node.
2. Với bước cần đối chiếu thời gian, gõ `date -Is` làm dòng đầu tiên **trong cùng khung hình** với lệnh kiểm tra.
3. Với bước so sánh hai node (replication, VIP), xếp **hai terminal cạnh nhau trong một ảnh**.
4. Lưu ảnh PNG vào `evidence/minh-hung/images/` theo đúng tên file đề xuất trong bảng mục 13.
5. Mỗi ảnh phải được trích dẫn trong biên bản `.md` tương ứng (`YYYYMMDD-minh-hung-<test>.md`).
6. Không che cửa sổ khác lên terminal; không crop mất dòng lệnh đã chạy.

## 1. Phạm vi và nguyên tắc

- Site B gồm 6 VM: `Transit-B`, `Firewall-A`, `Firewall-B`, `DB-Primary`, `DB-Replica`, `Log-Monitor`.
- Firewall áp dụng deny-by-default; mọi luồng cho phép phải có rule và log prefix riêng.
- Web và Database không cài Tailscale; liên site chỉ đi qua Transit-B.
- SSH quản trị chỉ hợp lệ từ vùng MANAGEMENT (`172.20.50.0/24`) hoặc jump path được kiểm soát.
- Không commit password, token, private key hoặc log chứa credential.

## 2. Kênh truy cập và phối hợp

### 2.1. Kênh SSH từ máy Quan Bảo (Site A)

```bash
# Vào Transit-B qua portproxy LAN của máy Hùng
ssh -p 2222 ops@192.168.1.26

# Vào Log-Monitor (jump 1 chặng qua Transit-B)
ssh -J ops@192.168.1.26:2222 ops@172.20.50.10

# Vào Firewall/DB (jump 2 chặng: Transit-B rồi Log-Monitor)
ssh -J ops@192.168.1.26:2222,ops@172.20.50.10 ops@172.20.50.2
ssh -J ops@192.168.1.26:2222,ops@172.20.50.10 ops@172.20.50.3
ssh -J ops@192.168.1.26:2222,ops@172.20.50.10 ops@172.20.40.11
ssh -J ops@192.168.1.26:2222,ops@172.20.50.10 ops@172.20.40.12
```

Lưu ý: không dùng `-J ... ops@172.20.50.10` khi đích cũng là `172.20.50.10`
(OpenSSH báo `jumphost loop`); Log-Monitor chỉ cần jump 1 chặng.

### 2.2. Kênh AI phối hợp

```bash
curl -s http://192.168.1.26:8080/status
curl -s http://192.168.1.26:8080/messages
curl -s -X POST http://192.168.1.26:8080/messages \
  -H "Content-Type: application/json" \
  -d '{"from":"Bao-AI","type":"test_start","content":"..."}'

python scripts/p2p/agent_peer.py --status
python scripts/p2p/agent_peer.py --handshake
python scripts/p2p/agent_peer.py --presence
python scripts/p2p/agent_peer.py --rpc query_db_replication
```

Ghi chú: bridge mangle dấu tiếng Việt trong trường `content`; nên gửi nội dung không dấu.

## 3. Pha 1 — Khởi động và baseline

### 3.1. Bật VM theo thứ tự

1. `Transit-B`
2. `Firewall-A`
3. `Log-Monitor`
4. `DB-Primary`
5. `DB-Replica` (khi cần test replication/failover)
6. `Firewall-B` (khi cần test HA firewall)

### 3.2. Kiểm tra baseline trên Transit-B

```bash
date -Is
hostname
ip -br addr
ip route
cat /proc/sys/net/ipv4/ip_forward
tailscale status
```

Kỳ vọng: route `172.20.0.0/16 via 172.20.20.1 dev eth0`, `ip_forward = 1`,
Transit-B online trên Tailscale.

[CHỤP ẢNH SB-01] Toàn bộ output 6 lệnh trên trong một cửa sổ, thấy prompt `ops@transit-b`,
dòng `date -Is`, route `/16` và `ip_forward = 1`.
Tên file: `YYYYMMDD-minh-hung-sb01-transit-b-baseline.png`

### 3.3. Kiểm tra dịch vụ trên từng VM

```bash
sudo -n systemctl is-active nftables        # Firewall-A/B
sudo -n systemctl is-active rsyslog         # Log-Monitor
sudo -n systemctl is-active postgresql      # DB-Primary/Replica
```

[CHỤP ẢNH SB-02] Ba cửa sổ terminal cạnh nhau: Firewall-A (`nftables active`),
Log-Monitor (`rsyslog active`), DB-Primary (`postgresql active`).
Tên file: `YYYYMMDD-minh-hung-sb02-services-active.png`

## 4. Pha 2 — Transit, routing và anti-bypass

Trên Transit-B:

```bash
date -Is
timeout 3 bash -c '</dev/tcp/172.20.40.11/5432'; echo db_exit=$?
timeout 3 bash -c '</dev/tcp/172.20.50.2/22';   echo ssh_exit=$?
ping -c 2 -W 2 172.20.40.11
```

Kỳ vọng: `db_exit=124`, `ssh_exit=124`, ping `0% packet loss`.

[CHỤP ẢNH SB-03] Một cửa sổ Transit-B thấy đủ: dòng `date -Is`, hai dòng `exit=124`
và kết quả ping 0% loss. Đây là ảnh chứng minh anti-bypass: DB và SSH quản trị không thể
đi thẳng qua transit, còn ICMP giám sát vẫn thông.
Tên file: `YYYYMMDD-minh-hung-sb03-anti-bypass-probes.png`

## 5. Pha 3 — Firewall policy và VIP

Trên Firewall-A:

```bash
sudo -n systemctl is-active nftables keepalived
sudo -n nft list ruleset | grep -E "policy drop|FW-" | head -40
ip -br addr | grep 172.20
```

Trên Firewall-B:

```bash
sudo -n systemctl is-active nftables keepalived
ip -br addr | grep 172.20
```

Kỳ vọng: `nftables` active trên cả hai; Firewall-A có `policy drop` và đủ prefix
`FW-ALLOW-WAN-VIP`, `FW-DENY-WAN-DIRECT`, `FW-ALLOW-WEB-DB`, `FW-ALLOW-DB-REPL`,
`FW-ALLOW-MGMT-SSH`, `FW-DEFAULT-DENY`, `FW-DENY-INPUT-DEFAULT`;
VIP gateway `.1` nằm trên Firewall-A và không nằm trên Firewall-B.

[CHỤP ẢNH SB-04] Cửa sổ Firewall-A thấy `policy drop` và danh sách prefix FW-*.
Tên file: `YYYYMMDD-minh-hung-sb04-fw-a-ruleset.png`

[CHỤP ẢNH SB-05] Hai cửa sổ cạnh nhau: `ip -br addr` của Firewall-A (có VIP `.1`)
và Firewall-B (không có VIP `.1`).
Tên file: `YYYYMMDD-minh-hung-sb05-vip-placement.png`

### GAP cần Hùng xác nhận

Trong phiên tích hợp, `keepalived.service` không tồn tại trên cả hai firewall
(`Unit keepalived.service could not be found`) và VIP `.1` nằm tĩnh trên Firewall-A.
Không ghi nhận firewall failover là PASS cho tới khi Hùng xác nhận cơ chế HA thực tế
hoặc cài/khôi phục cơ chế chuyển VIP.

[CHỤP ẢNH SB-06] Hai cửa sổ cạnh nhau hiển thị kết quả
`systemctl is-active keepalived` trên Firewall-A và Firewall-B (trạng thái hiện tại),
dùng làm evidence cho GAP và làm mốc trước khi khắc phục.
Tên file: `YYYYMMDD-minh-hung-sb06-keepalived-gap.png`

## 6. Pha 4 — Negative security và đối soát log

### 6.1. Bắn probe từ nguồn không được phép

Từ Transit-B (nguồn `172.20.20.6`):

```bash
date -Is
timeout 3 bash -c '</dev/tcp/172.20.40.11/5432'; echo db_exit=$?
timeout 3 bash -c '</dev/tcp/172.20.50.2/22';   echo ssh_exit=$?
```

[CHỤP ẢNH SB-07] Cửa sổ Transit-B với `date -Is` và hai kết quả `exit=124`.
Tên file: `YYYYMMDD-minh-hung-sb07-negative-probes.png`

### 6.2. Đối soát log cục bộ trên Firewall-A

Chạy ngay sau probe, trong vòng vài phút:

```bash
date -Is
sudo -n journalctl -k --since "10 minutes ago" --no-pager | grep "SRC=172.20.20.6" | tail -8
sudo -n nft list chain inet filter forward | grep DEFAULT-DENY
sudo -n nft list chain inet filter input   | grep INPUT-DEFAULT
```

Kỳ vọng: log `FW-DEFAULT-DENY` với `DST=172.20.40.11 DPT=5432` và
`FW-DENY-INPUT-DEFAULT` với `DST=172.20.50.2 DPT=22`; counter tăng so với trước probe.

[CHỤP ẢNH SB-08] Cửa sổ Firewall-A thấy dòng log deny có `SRC=172.20.20.6` trùng khung giờ
với ảnh SB-07, kèm counter của hai rule deny.
Tên file: `YYYYMMDD-minh-hung-sb08-fw-a-deny-log.png`

### 6.3. Đối soát log tập trung trên Log-Monitor

```bash
date -Is
sudo -n ls -R /var/log/central | head -20
sudo -n sh -c 'grep -rh "SRC=172.20.20.6" /var/log/central/fw-a | tail -4'
```

[CHỤP ẢNH SB-09] Cửa sổ Log-Monitor thấy danh sách thư mục `fw-a`, `fw-b`, `db-primary`,
`db-replica`, `transit-b` và dòng log deny trùng timestamp với SB-07/SB-08.
Tên file: `YYYYMMDD-minh-hung-sb09-central-deny-log.png`

Bộ ba SB-07, SB-08, SB-09 phải chụp trong cùng một lượt chạy để timestamp khớp nhau.

## 7. Pha 5 — Database replication và least privilege

### 7.1. Trạng thái replication

Trên DB-Primary và DB-Replica, chạy cùng lúc hai cửa sổ cạnh nhau:

```bash
date -Is
sudo -n -u postgres psql -t -c "SELECT pg_is_in_recovery();"
sudo -n -u postgres psql -d ha_lab_db -t -c "SELECT id,node_name,status FROM health_checks ORDER BY id DESC LIMIT 3;"
```

Kỳ vọng: Primary trả `f`, Replica trả `t`, ba dòng mới nhất giống hệt nhau.

[CHỤP ẢNH SB-10] Hai cửa sổ cạnh nhau (Primary trái, Replica phải) thấy `f` / `t`
và cùng ba dòng dữ liệu.
Tên file: `YYYYMMDD-minh-hung-sb10-replication-sync.png`

### 7.2. Least privilege với app_user

Trên DB-Primary:

```bash
date -Is
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db \
  -c "INSERT INTO health_checks(node_name,status) VALUES ('SB-LEAST-PRIV','OK') RETURNING id;"
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db \
  -c "DELETE FROM health_checks WHERE node_name='SB-LEAST-PRIV';"
```

Kỳ vọng: INSERT trả về id; DELETE báo `ERROR: permission denied for table health_checks`.

[CHỤP ẢNH SB-11] Cửa sổ DB-Primary thấy INSERT trả id và DELETE bị `permission denied`
trong cùng khung hình.
Tên file: `YYYYMMDD-minh-hung-sb11-least-privilege.png`

Trên DB-Replica, kiểm tra dòng vừa INSERT đã sang:

```bash
sudo -n -u postgres psql -d ha_lab_db -t -c "SELECT id,node_name FROM health_checks WHERE node_name='SB-LEAST-PRIV';"
```

[CHỤP ẢNH SB-12] Cửa sổ DB-Replica thấy đúng dòng `SB-LEAST-PRIV` với id trùng ảnh SB-11.
Tên file: `YYYYMMDD-minh-hung-sb12-replica-received-row.png`

## 8. Pha 6 — Database failover và rejoin

### 8.1. Failover

Trên DB-Primary:

```bash
date -Is
sudo -n systemctl stop postgresql
sudo -n systemctl is-active postgresql
```

Kỳ vọng: `inactive`.

[CHỤP ẢNH SB-13] Cửa sổ DB-Primary thấy `date -Is`, lệnh stop và trạng thái `inactive`.
Tên file: `YYYYMMDD-minh-hung-sb13-primary-stopped.png`

Trên DB-Replica:

```bash
date -Is
sudo -n -u postgres psql -c "SELECT pg_promote(wait => true, wait_seconds => 30);"
sudo -n -u postgres psql -t -c "SELECT pg_is_in_recovery();"
PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db \
  -c "INSERT INTO health_checks(node_name,status) VALUES ('SB-FAILOVER','OK') RETURNING id;"
```

Kỳ vọng: promote trả `t`, `pg_is_in_recovery()` trả `f`, INSERT trả id mới.

[CHỤP ẢNH SB-14] Cửa sổ DB-Replica thấy đủ bốn kết quả trên; timestamp ở đây trừ timestamp
ở SB-13 chính là RTO cần ghi vào biên bản.
Tên file: `YYYYMMDD-minh-hung-sb14-replica-promoted.png`

### 8.2. Rejoin Primary cũ thành Standby

Cảnh báo: bước này xóa data directory của node cũ. Chỉ chạy khi đã xác định đúng VM
và Replica mới đang là Primary ổn định. Không khởi động Primary cũ trước khi rejoin
(nguy cơ split-brain).

Trên DB-Primary cũ (`172.20.40.11`):

```bash
date -Is
sudo -n systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/16/main/*
sudo -u postgres pg_basebackup \
  -h 172.20.40.12 -p 5432 -U repl_user \
  -D /var/lib/postgresql/16/main -Fp -Xs -P -R
sudo -n systemctl start postgresql
sudo -n -u postgres psql -t -c "SELECT pg_is_in_recovery();"
```

Kỳ vọng: `pg_basebackup` chạy tới 100%, node cũ trả `t`.

[CHỤP ẢNH SB-15] Cửa sổ DB-Primary cũ thấy tiến độ `pg_basebackup` và kết quả
`pg_is_in_recovery() = t` sau khi start.
Tên file: `YYYYMMDD-minh-hung-sb15-primary-rejoined.png`

## 9. Pha 7 — Firewall HA failover (chờ xác nhận cơ chế)

Chỉ chạy sau khi Pha 3 xác nhận cơ chế HA tồn tại.

1. Ghi timestamp; trên Firewall-A dừng cơ chế HA (ví dụ `sudo -n systemctl stop keepalived`).
2. Trên Firewall-B kiểm tra VIP:

```bash
date -Is
ip -br addr | grep 172.20.20.1
```

[CHỤP ẢNH SB-16] Cửa sổ Firewall-B thấy VIP `.1` xuất hiện sau khi Firewall-A dừng cơ chế HA.
Tên file: `YYYYMMDD-minh-hung-sb16-vip-on-fw-b.png`

3. Từ client bắn lại probe negative của Pha 4; trên Firewall-B xem log deny:

```bash
sudo -n journalctl -k --since "5 minutes ago" --no-pager | grep -E "FW-DEFAULT-DENY|FW-DENY-INPUT" | tail -5
```

[CHỤP ẢNH SB-17] Hai cửa sổ cạnh nhau: probe bị chặn phía client và log deny phía Firewall-B
trong thời gian failover.
Tên file: `YYYYMMDD-minh-hung-sb17-negative-during-failover.png`

4. Failback: khởi động lại cơ chế HA trên Firewall-A, xác nhận VIP trở về:

```bash
date -Is
ip -br addr | grep 172.20.20.1
```

[CHỤP ẢNH SB-18] Cửa sổ Firewall-A thấy VIP `.1` trở lại sau failback.
Tên file: `YYYYMMDD-minh-hung-sb18-vip-failback.png`

## 10. Pha 8 — Log tập trung và đối chiếu timestamp

Trên Log-Monitor:

```bash
date -Is
sudo -n systemctl is-active rsyslog
sudo -n netstat -tlnp | grep 514
sudo -n ls -lh /var/log/central/
sudo -n sh -c 'tail -n 10 /var/log/central/fw-a/kernel.log'
```

Đối chiếu: chọn một mốc probe ở Pha 4 và một mốc failover ở Pha 6/7; xác nhận log tương ứng
xuất hiện trong `/var/log/central/<host>/` với timestamp lệch không quá vài giây so với
log cục bộ trên node nguồn.

[CHỤP ẢNH SB-19] Cửa sổ Log-Monitor thấy rsyslog active, port 514 listening, danh sách file
log theo host và các dòng tail trùng mốc thời gian đã chụp ở SB-08/SB-14.
Tên file: `YYYYMMDD-minh-hung-sb19-central-logging.png`

## 11. Pha 9 — Kết thúc và trạng thái cuối

1. Failback toàn bộ: DB-Primary cũ về Standby, VIP firewall về Firewall-A.
2. Chạy lại kiểm tra nhanh: replication đồng bộ, VIP đúng node, log central còn chảy.
3. Gửi tin tổng kết qua bridge/PAL kèm danh sách test PASS/GAP.
4. Cập nhật `lab/testing/minh-hung/test-cases-minh-hung.md` và acceptance matrix chung.

[CHỤP ẢNH SB-20] Một ảnh ghép hoặc ba cửa sổ cạnh nhau chốt trạng thái cuối:
replication `f`/`t` đồng bộ, VIP `.1` trên Firewall-A, log central vẫn nhận dòng mới.
Tên file: `YYYYMMDD-minh-hung-sb20-final-state.png`

## 12. Bảng tóm tắt test và evidence

| ID | Hạng mục | Lệnh chính | Kỳ vọng | Ảnh minh chứng |
|---|---|---|---|---|
| SB-01 | Baseline Transit-B | `ip route`, `ip_forward` | route `/16` qua `.20.1`, forward=1 | sb01 |
| SB-02 | Dịch vụ active | `systemctl is-active` | nftables/rsyslog/postgresql active | sb02 |
| SB-03 | Anti-bypass | probe `/dev/tcp`, ping | exit 124; ping 0% loss | sb03 |
| SB-04 | Firewall policy | `nft list ruleset` | policy drop + đủ prefix | sb04 |
| SB-05 | VIP placement | `ip -br addr` 2 FW | VIP trên node active | sb05 |
| SB-06 | Trạng thái keepalived | `systemctl is-active keepalived` | ghi nhận GAP hiện tại | sb06 |
| SB-07 | Negative probes | probe từ Transit-B | exit 124 | sb07 |
| SB-08 | Deny log cục bộ | `journalctl -k` | FW-DEFAULT-DENY khớp probe | sb08 |
| SB-09 | Deny log tập trung | grep `/var/log/central/fw-a` | cùng timestamp | sb09 |
| SB-10 | Replication | `pg_is_in_recovery()` | f / t, dữ liệu giống nhau | sb10 |
| SB-11 | Least privilege | INSERT/DELETE app_user | INSERT ok, DELETE denied | sb11 |
| SB-12 | Replica nhận dòng mới | SELECT trên Replica | id trùng SB-11 | sb12 |
| SB-13 | Dừng Primary | `systemctl stop postgresql` | inactive + timestamp | sb13 |
| SB-14 | Promote Replica | `pg_promote()` | f + ghi được + RTO | sb14 |
| SB-15 | Rejoin Standby | `pg_basebackup -R` | node cũ trả t | sb15 |
| SB-16 | VIP sang Firewall-B | `ip -br addr` | VIP `.1` trên FW-B | sb16 |
| SB-17 | Negative khi failover | probe + log FW-B | vẫn chặn + có log | sb17 |
| SB-18 | Failback VIP | `ip -br addr` FW-A | VIP trở về FW-A | sb18 |
| SB-19 | Central logging | `ls` + `tail` log central | đủ nguồn, khớp timestamp | sb19 |
| SB-20 | Trạng thái cuối | kiểm tra nhanh 3 mục | hệ thống về trạng thái chuẩn | sb20 |

## 13. Quy ước tên file ảnh

Tất cả ảnh lưu tại `evidence/minh-hung/images/` với mẫu:

```text
YYYYMMDD-minh-hung-sb<id>-<ten-ngan>.png
```

Ví dụ cụ thể cho ngày chạy thực tế:

```text
20261110-minh-hung-sb10-replication-sync.png
20261110-minh-hung-sb14-replica-promoted.png
```

## 14. Nguyên tắc an toàn khi chạy kịch bản

- Chỉ chạy trong mạng lab cô lập; probe negative chỉ bắn vào địa chỉ lab.
- Không chạy `rm -rf` data directory ngoài đúng bước rejoin đã xác nhận.
- Dừng Primary trước khi promote Replica; không để hai node cùng nghĩ mình là Primary.
- Mọi kết luận PASS phải kèm output hoặc log; GAP phải ghi rõ lý do và người xác nhận.
- Không đưa password thật vào evidence; mật khẩu demo chỉ dùng trong lab và ghi rõ là placeholder.
- Ảnh evidence không được chứa cửa sổ khác lộ thông tin nhạy cảm (token, mật khẩu, tab trình duyệt).
