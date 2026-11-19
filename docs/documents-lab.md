# Tài liệu toàn diện bài lab HA-LB-Security

> Tài liệu tham chiếu chung cho cả hai thành viên. Mục tiêu: đọc một lần là hiểu
> toàn bộ bài lab — kiến trúc, cơ chế bảo mật, cơ chế HA, cách kiểm thử, kết quả
> hiện tại, khoảng trống còn lại và kịch bản demo cuối kỳ.
> Chi tiết thao tác theo từng batch nằm trong `joint-lab-test-runbook.md`;
> chi tiết Site B theo mốc SB nằm trong `site-b-comprehensive-scenario.md`.

## 1. Bài lab là gì

Một hệ thống mạng riêng mô phỏng doanh nghiệp hai site, chạy hoàn toàn trên VMware
Workstation của hai máy tính cá nhân nối với nhau bằng Tailscale:

- **Site A** (máy Quan Bảo): dịch vụ web sẵn sàng cao — load balancer, VIP, hai web node.
- **Site B** (máy Minh Hùng): an ninh và dữ liệu — firewall deny-by-default,
  PostgreSQL replication, log tập trung.

Bài lab chứng minh bốn điều:

1. **Kiểm soát truy cập:** mọi đường vào vùng dữ liệu/quản trị phải qua firewall;
   truy cập trái phép bị chặn và lại còn ghi được log.
2. **Sẵn sàng cao tầng web:** một web node chết thì dịch vụ vẫn sống qua VIP.
3. **Sẵn sàng cao tầng dữ liệu:** primary chết thì replica được promote và ghi tiếp,
   node cũ rejoin làm standby.
4. **Kiểm toán:** toàn bộ sự kiện allow/deny tập trung về một máy log, đối chiếu
   được theo timestamp với lúc test.

## 2. Kiến trúc tổng thể

```text
        Máy Windows Bảo                                Máy Windows Hùng
   192.168.1.7 / 100.82.115.17                  192.168.1.26 / 100.76.150.63
   (PAL-v2 node, portproxy client)              (PAL-v2 node, portproxy 2222/8080)
        |         \                                    /         |
        |          Tailscale tailnet (ACL + routes)   |          |
   [Transit-A] ---------------------------------- [Transit-B]    |
   172.20.21.5      advertise 21.0/24       advertise 20/40/50  [bridge:8080]
        |           172.20.20.6                                   on Transit-B
   [LB-A VIP 172.20.21.100]                          |
        |                                    [Firewall-A 172.20.x.1/.2]
   [Web-A .20] [Web-B .30]                    [Firewall-B 172.20.x.3]
                                                    |        |        \
                                              [DMZ .20]  [DB .40]  [MGMT .50]
                                                          |            |
                                              [DB-Primary .11]   [Log-Monitor .10]
                                              [DB-Replica .12]
```

Hai lớp mạng phân biệt rõ:

- **Data plane:** lưu lượng dịch vụ/kiểm thử đi VM → transit → firewall → vùng đích.
  Tailscale chỉ chạy trên hai Transit VM.
- **Coordination plane:** hai AI/host phối hợp qua bridge HTTP (`:8080`) và PAL-v2
  (`:8088`). Kênh này không nằm trong phạm vi nghiệm thu an ninh.

## 3. Mô hình mạng và địa chỉ

| Vùng | Subnet | VM / địa chỉ | Vai trò |
|---|---|---|---|
| WAN-LAB | `172.20.10.0/24` | Test-Client (theo spec: `.10`) | Nguồn không tin cậy |
| DMZ / Transit-B | `172.20.20.0/24` | Transit-B `.6`, gateway `.1`, FW-A `.2`, FW-B `.3` | Biên Site B, điểm vào từ overlay |
| Site A service | `172.20.21.0/24` | Transit-A `.5`, LB-A `.10`, Web-A `.20`, Web-B `.30`, Test-Client `.40`, VIP `.100` | Toàn bộ tầng web |
| APP | `172.20.30.0/24` | (vùng thiết kế mở rộng) | Tầng ứng dụng |
| DATABASE | `172.20.40.0/24` | DB-Primary `.11`, DB-Replica `.12`, gateway `.1` | Dữ liệu, cô lập khỏi WAN |
| MANAGEMENT | `172.20.50.0/24` | FW-A `.2`, FW-B `.3`, Log-Monitor `.10`, gateway `.1` | SSH quản trị + syslog |

Cổng dịch vụ chính:

| Port | Dịch vụ | Phạm vi được phép |
|---|---|---|
| 80, 443 | HTTP/HTTPS qua VIP | WAN→VIP; Site A qua overlay |
| 5432 | PostgreSQL | Web node → DB; DB ↔ DB replication |
| 22 | SSH | Chỉ từ MANAGEMENT hoặc jump path `[FW-ALLOW-SITE-A-JUMP]` |
| 514 | syslog UDP | Mọi VM → Log-Monitor |
| 8080 | bridge AI | LAN/portproxy |
| 8088 | PAL-v2 | LAN giữa hai host |

## 4. Site A — thiết kế và kết quả

### 4.1. Cơ chế

- **Transit-A:** Tailscale subnet router quảng bá `172.20.21.0/24`, `ip_forward=1`,
  accept route Site B để Test-Client bắn được test chéo.
- **LB-A:** HAProxy kết thúc TLS (cert lab tự ký), round-robin Web-A/Web-B,
  health check `GET /healthz`, stats có mật khẩu tại `172.20.21.10:8404`;
  Keepalived một node giữ VIP `172.20.21.100`.
- **Web-A/Web-B:** Nginx, trang nhận diện node riêng, access log, SSH key-only.

### 4.2. Đã kiểm chứng (evidence `evidence/quan-bao/`)

| Kiểm thử | Kết quả |
|---|---|
| Route overlay vào Site A (ping TTL=63, curl) | PASS |
| `/healthz` 200 cả hai node | PASS |
| HTTPS round-robin qua VIP | PASS |
| HAProxy stats: hai backend UP | PASS |
| Web-A dừng → Web-B phục vụ toàn bộ | PASS |
| Web-A khôi phục → quay lại pool | PASS |
| SSH key-only, từ chối password/root | PASS |
| Cert lab không được tin cậy mặc định (negative) | PASS |
| Stats yêu cầu mật khẩu (401/200) | PASS |

## 5. Site B — thiết kế và kết quả

### 5.1. Transit-B

- Quảng bá `172.20.20.0/24`, `172.20.40.0/24`, `172.20.50.0/24` (đã approve thủ công
  cho `.40` và `.50` theo policy).
- Route nội bộ dạng tổng hợp `172.20.0.0/16 via 172.20.20.1` — mọi lưu lượng vào
  DB/MGMT bắt buộc qua Firewall-A, không có đường bypass.
- Chạy bridge HTTP `:8080` và được portproxy qua `192.168.1.26:2222/:8080`.

### 5.2. Firewall-A/B (nftables)

- `policy drop` ở cả input và forward; anti-spoofing theo interface từng vùng.
- Rule chính: `FW-ALLOW-WAN-VIP` (WAN→VIP 80/443), `FW-DENY-WAN-DIRECT` (chặn thẳng
  Web/DB/MGMT/APP từ WAN), `FW-ALLOW-WEB-DB` (chỉ web node tới `.11/.12:5432`),
  `FW-ALLOW-DB-REPL` (chỉ `.11 ↔ .12`), `FW-ALLOW-MGMT-SSH` (chỉ dải MGMT source 22),
  `FW-ALLOW-SYSLOG` (514 về `.10`), `FW-ALLOW-SITE-A-JUMP` (rule mở rộng phục vụ
  jump path liên site), DNAT `FW-NAT-DNAT-VIP`.
- Gateway VIP `.1` hiện **gán tĩnh trên Firewall-A**.

### 5.3. Database

- PostgreSQL 16, streaming replication `repl_user`, slot riêng.
- `app_user`: được INSERT/UPDATE, **không** được DELETE/DROP (least privilege).
- Failover: stop Primary → `pg_promote(wait => true, wait_seconds => 30)` → Replica
  thành Read-Write; rejoin node cũ bằng `pg_basebackup -R` (không khởi động node cũ
  trước rejoin để tránh split-brain).

### 5.4. Monitoring

- rsyslog tập trung tại `172.20.50.10:/var/log/central/<host>/`, thu đủ
  `fw-a`, `fw-b`, `db-primary`, `db-replica`, `transit-b`.

### 5.5. Đã kiểm chứng (evidence `evidence/minh-hung/` + phiên chung)

| Kiểm thử | Kết quả |
|---|---|
| Route + anti-bypass Transit-B | PASS |
| Negative DB 5432 từ nguồn ngoài → `FW-DEFAULT-DENY` + log | PASS |
| Direct SSH tới firewall → `FW-DENY-INPUT-DEFAULT` + log | PASS |
| ICMP DB được policy cho phép | PASS |
| Jump path Site A → Log-Monitor → FW/DB | PASS |
| Replication: Primary `f` / Replica `t`, dữ liệu khớp | PASS |
| Least privilege: INSERT OK, DELETE `permission denied` | PASS |
| DB failover: promote + ghi mới (RTO ghi theo timestamp) | PASS |
| Log tập trung khớp timestamp test | PASS |
| Firewall HA tự động (VRRP/keepalived) | **GAP — xem mục 8** |

## 6. Kết nối liên site và kênh quản trị

### 6.1. Tailscale

- Tailnet dùng chung; ACL khóa: thiết bị admin chỉ SSH transit + MGMT;
  transit-a chỉ tới DMZ 80/443, DB `.11/.12:5432`, syslog `.10:514`;
  **không** mở cả dải DB cho thiết bị cá nhân.
- Route approve thủ công cho `.40/.50`; hai đầu phải `--accept-routes`.

### 6.2. Đường SSH kiểm chứng thực tế (thứ tự ưu tiên)

1. **Chính — LAN portproxy:** `ssh -p 2222 ops@192.168.1.26` vào Transit-B;
   jump vào Log-Monitor (`-J ops@192.168.1.26:2222 ops@172.20.50.10`);
   jump kép vào FW/DB (`-J ops@192.168.1.26:2222,ops@172.20.50.10 ops@<ip>`).
   Ổn định, không phụ thuộc tailscaled của VM.
2. **Phụ — Tailscale route:** `ssh ops@172.20.20.6`... (từng chập chờn khi
   tailscaled Transit-B treo).
3. SSH thẳng vào `50.2`/`40.x` từ ngoài MGMT bị DROP **đúng thiết kế** — giữ làm
   negative evidence, không phải lỗi.

## 7. Phương pháp kiểm thử chung

- **Positive:** chứng minh luồng được phép hoạt động (VIP, round-robin, replication,
  jump path, syslog).
- **Negative:** chứng minh luồng bị chặn **và** có log prefix tương ứng; probe phải
  bắn từ đúng nguồn theo thiết kế (Test-Client/Transit) để firewall là tầng chặn,
  tránh trường hợp bị chặn bởi ACL mà không sinh log.
- **Cặp bằng chứng:** ảnh phía client (kết quả chặn) + ảnh phía firewall/log (dòng
  deny) chụp trong cùng cửa sổ thời gian, có `date -Is`.
- **Đo RTO:** timestamp trước khi hạ node, timestamp khi dịch vụ ghi/hoạt động lại.
- **Ảnh evidence:** `YYYYMMDD-owner-<test>.png` trong `evidence/<owner>/images/`,
  kèm biên bản `.md` ghi lệnh/expected/actual; mốc J cho Bảo, mốc SB cho Hùng.

## 8. Trạng thái GAP còn lại (2026-11-10)

| GAP | Hiện trạng | Xử lý |
|---|---|---|
| **Firewall HA tự động** | `keepalived` chưa được cài trên Firewall-A/B (cả hai trả `inactive`, rc=3). HA hiện đạt bằng **manual Gateway IP migration** (gỡ/gán VIP + gratuitous ARP theo runbook), chưa phải VRRP tự động | Hùng quyết định: (a) cài keepalived hai node cùng VRID/priority và chạy J-11/J-12, hoặc (b) nghiệm thu ở mức manual migration và ghi rõ giới hạn trong báo cáo |
| **VIP `172.20.20.100`** | DMZ Site B chưa có web service phía sau (evidence của Hùng có `[WARN]` không kết nối được). Positive web dùng VIP Site A `172.20.21.100` | Ghi là hạng mục tích hợp mở; không dùng 20.100 làm positive test |
| **Git artifact** | Ảnh/runbook chung mới (C-01, J-01..J-13, SB) và README mới đang untracked/modified, chưa commit/push | Phân loại rồi stage chọn lọc; **không** commit `scripts/p2p/peer_agent.db`, `scripts/p2p/transfers/`; Bảo duyệt commit và tự push |

## 9. Kịch bản demo cuối kỳ (đề xuất 15 phút)

| Phút | Nội dung | Ai thao tác | Điểm nhấn |
|---|---|---|---|
| 0–2 | Kiến trúc, trust boundary, PAL `--presence` | Cả hai | Hai site một màn hình phối hợp |
| 2–5 | VIP Site A round-robin + web failover (dừng Web-A) | Bảo | HAProxy stats UP/MAX |
| 5–8 | Negative chéo site: DB 5432, SSH trái phép | Bảo bắn, Hùng mở log | Cặp client-blocked + `FW-DENY` timestamp khớp |
| 8–11 | DB: replication → stop Primary → promote → ghi mới | Hùng (Bảo quan sát/jump) | RTO trên màn hình |
| 11–13 | Gateway migration Firewall-A→B (manual hoặc keepalived nếu đã cài) | Hùng | VIP `.1` đổi chủ, policy không hở |
| 13–15 | Central log đối chiếu + acceptance matrix | Cả hai | Đủ 4 tầng log, PASS/GAP rõ ràng |

## 10. Acceptance matrix (draft — chốt sau khi đối chiếu)

| Nhóm | Tiêu chí | Kết quả | Evidence |
|---|---|---|---|
| Transit | Route advertise/approve/accept đúng phạm vi | PASS | C-01, J-03, SB-01 |
| Transit | Không bypass firewall | PASS | J-03, SB-03 |
| Firewall | Deny-by-default + log prefix đủ bộ | PASS | J-04, SB-04 |
| Firewall | Negative DB/SSH bị chặn có log | PASS | J-05/J-06, SB-07..09 |
| Firewall | HA tự động VRRP | **GAP** | SB-06 |
| Firewall | Gateway migration thủ công A→B→A | PASS (manual) | J-11/J-12, SB-16..18 |
| Web/LB | VIP, round-robin, failover, healthz | PASS | evidence Site A 20261108/09 |
| DB | Replication + least privilege | PASS | J-07/J-08, SB-10..12 |
| DB | Failover + rejoin, có RTO | PASS | J-09/J-10, SB-13..15 |
| Monitoring | Log tập trung khớp timestamp | PASS | J-13, SB-19 |
| Tích hợp mở | WAN → VIP Site B web | OPEN | ghi nhận, không tính FAIL |

## 11. Troubleshooting nhanh

| Triệu chứng | Nguyên nhân hay gặp | Xử lý |
|---|---|---|
| `Permission denied (publickey)` | Key chưa add vào VM đích | Hùng chạy vòng lặp add key; `grep qoder-local ~/.ssh/authorized_keys` |
| Timeout mọi đường Site B | VM suspend hoặc tailscaled treo | Hùng kiểm VMware + `systemctl restart tailscaled`; dùng portproxy LAN |
| `jumphost loop` | Đặt jump trùng đích | Log-Monitor chỉ jump 1 chặng |
| Negative test không sinh log firewall | Bị chặn ở ACL trước firewall | Bắn từ Test-Client/Transit (nguồn đi tới firewall) |
| Bridge/PAL báo OFFLINE | Portproxy/firewall Windows một bên | `netsh interface portproxy show all`; rule inbound 2222/8080/8088 |
| Replica không nhận dòng mới | WAL chưa replay / replica tắt | Chờ replay vài giây; kiểm tra `pg_stat_replication` |

## 12. Bản đồ tài liệu

| Tài liệu | Dùng khi |
|---|---|
| `README.md` | Giới thiệu nhanh tổng quan |
| `docs/documents-lab.md` (file này) | Hiểu toàn bộ bài lab |
| `docs/quan-bao/joint-lab-test-runbook.md` | Chạy batch chung C-01, J-01..J-13 |
| `docs/quan-bao/site-b-comprehensive-scenario.md` | Hùng chạy chi tiết Site B, mốc ảnh SB |
| `docs/p2p-agent-protocol.md` | Vận hành PAL-v2 |
| `lab/firewall/`, `lab/database/`, `lab/load-balancer/`... | Runbook thiết kế từng tầng |
| `evidence/quan-bao/`, `evidence/minh-hung/` | Biên bản và ảnh đã thu |
