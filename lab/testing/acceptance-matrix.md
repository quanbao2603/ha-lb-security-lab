# Acceptance Matrix — Site A/B

**Ngày kiểm thử gần nhất:** 2026-11-17 (chạy lại toàn diện, một lần liên tục)  
**Site B owner:** Minh Hùng  
**Site A owner:** Quan Bảo  
**Evidence chính (mới nhất):** `evidence/minh-hung/20261117-minh-hung-full-lab-rerun.md` — 34 ảnh chụp terminal thật + 34 transcript, đã OCR kiểm chứng  
**Ảnh chụp terminal:** `evidence/minh-hung/images/20261117-minh-hung-*.png`  
**Transcript thô:** `evidence/minh-hung/logs/20261117-*.log`  
**Evidence cũ (giữ làm lịch sử):** `20261112-minh-hung-site-b-comprehensive.md`, `20261113-minh-hung-vrrp-keepalived.md`, `images/20261116-minh-hung-vrrp-*.png`  
**Evidence joint Site A/B:** `evidence/quan-bao/20261110-quan-bao-joint-integration.md`

> Matrix tổng hợp kết quả trong repository. Lần chạy **2026-11-17** thay thế các ảnh render-từ-log của biên bản joint và các ảnh cũ đã lệch trạng thái: mỗi bước là một phiên SSH thật trên cửa sổ terminal riêng (`bash -x`, chụp bằng `PrintWindow`), không dựng lại ảnh. Baseline (A=5 VIP, B=0; `.12` Primary, `.11` Standby) đã được khôi phục và chụp lại ở SB-27/SB-28 sau toàn bộ chuỗi failover.

| ID | Phạm vi | Tiêu chí nghiệm thu | Kết quả gần nhất | Evidence |
|---|---|---|---|---|
| C-01 | Site A | Site A sống và tới được từ Site B; route qua `tailscale0` | PASS — 17/11: HTTP VIP `172.20.21.100/healthz` = **200**, route `172.20.21.5 dev tailscale0` | `20261117-minh-hung-C-01-joint-site-a-reachable.png` |
| J-01 | Liên site | Site A đi qua Transit-B vào Log-Monitor | PASS | `evidence/quan-bao/` + C-01 17/11 |
| J-02 | Firewall | Site-A jump có rule và log | **KHÔNG CÒN ÁP DỤNG** — rule tạm `FW-ALLOW-SITE-A-JUMP` đã gỡ khỏi cả A và B (`grep -c SITE-A` = 0) | Joint integration (lịch sử 10/11) |
| J-03 | Transit-B | Route DB/MGMT qua Firewall-A, forwarding bật | PASS | SB-01 |
| J-04 | Firewall | nftables active, deny-by-default, VIP gateway | PASS | SB-04, SB-05a, SB-05b |
| J-05 | Management | SSH quản trị qua đường được phép | PASS | SB-04 (`FW-ALLOW-MGMT-SSH`) |
| J-06 | Security | WAN/Transit truy cập DB 5432 bị chặn | PASS — `.12`/`.11` đều `exit=124` | SB-03, SB-07, SB-16 |
| J-07 | Database | Streaming replication và dữ liệu đồng bộ | PASS — `.12 -> .11 streaming async`, slot active, `sent_lsn = replay_lsn` | SB-10a, SB-10b, SB-27, SB-28 |
| J-08 | Database | Least privilege: INSERT/UPDATE được, DELETE/DROP bị từ chối | PASS — grants = `INSERT, SELECT, UPDATE`; DELETE `permission denied`; DROP `must be owner` | SB-11, SB-12 |
| J-09 | Database | Promote Replica và ghi dữ liệu khi Primary dừng | PASS — 17/11: `pg_promote` trả `t`, role `t → f`, ghi id=148 | SB-19, SB-20, SB-22a, SB-22b |
| J-10 | Database | Primary cũ rejoin thành Standby | PASS — `pg_basebackup 100%`, `.12` trả `t` ngay lần đầu | SB-21, SB-26 |
| J-11 | Firewall HA | Dừng Keepalived trên A → B tự nhận đủ 5 VIP, deny policy intact | PASS — VRRP unicast, ~1 giây, negative vẫn chặn | SB-13, SB-14, SB-15, SB-16 |
| J-12 | Firewall HA | Khởi động lại Keepalived trên A → A tự preempt lấy lại 5 VIP | PASS — preempt 150 > 100 | SB-17, SB-18 |
| J-13 | Monitoring | Central syslog nhận log firewall, listener 514 UDP+TCP | PASS — cùng sự kiện deny xuất hiện ở `/var/log/central/fw-a/kernel.log` | SB-02b, SB-09 |
| GAP-01 | Firewall HA | `keepalived`/VRRP service tồn tại và active trên FW-A/B | RESOLVED — `2.2.7`, `active`, `enabled`, cả hai config `exit=0`, healthcheck `exit=0` | SB-06 |
| A-01 | Site A | `/healthz` trả 200 trên Web-A/Web-B | PASS | `evidence/quan-bao/`; xác nhận lại qua C-01 17/11 |
| A-02 | Site A | HTTPS VIP phân phối round-robin | PASS | `evidence/quan-bao/` |
| A-03 | Site A | Web failover qua VIP | PASS | `evidence/quan-bao/` |
| A-04 | Site A | SSH key-only trên web nodes | PASS | `evidence/quan-bao/` |

## Diễn biến chạy lại toàn diện (2026-11-17)

- **Phương pháp:** mỗi bước một phiên SSH thật trên cửa sổ terminal riêng, `bash -x` in ra lệnh thật trước khi thực thi; ảnh chụp bằng `PrintWindow`, không render từ log.
- **Baseline đầu phiên:** Firewall-A `keepalived=active nftables=active VIP=5` (MASTER); Firewall-B `active/active VIP=0` (BACKUP); `.12` Primary, `.11` Standby.
- **Firewall failover:** `01:43:33` dừng Keepalived **chỉ trên A** → A `inactive VIP=0`, B `VIP_COUNT=5` với `VRRP_Group(VG_FW) Syncing instances to MASTER state` và 5 dòng `Entering MASTER STATE` cùng giây.
- **Negative khi B giữ VIP:** DB `5432` = `124`, VIP SSH = `124`, syslog `514` = `0` (đường hợp lệ vẫn thông), gateway `.40.1` 0% loss.
- **Firewall failback:** `01:49:44` start Keepalived trên A → A `VIP=5` (preempt 150 > 100), B `VIP=0`; cả hai `keepalived_cfg_exit=0`, `nft_cfg_exit=0`.
- **DB failover:** `01:55` dừng `.12` → `01:56` promote `.11` (`t → f`), ghi dòng `SB-DB-FAILOVER` (id=148) → `01:58` rejoin `.12` (`pg_basebackup 100%`, trả `t`).
- **DB failback:** `02:21` promote `.12` về Primary → `02:25` rejoin `.11` thành Standby → `02:28` streaming `async` phục hồi, `sent_lsn = replay_lsn = 0/12000060`.
- **Logging:** rsyslog listen `172.20.50.10:514` cả UDP và TCP; log deny của Firewall-A về tới `/var/log/central/fw-a/`.

### Vấn đề phát hiện trong lần chạy này

1. **Replication slot không đi theo node khi promote.** Sau promote, primary mới không có `replica_slot_1`; standby báo `FATAL: replication slot "replica_slot_1" does not exist` và retry vô hạn trong khi `systemctl is-active postgresql` vẫn `active`. Khắc phục: `select pg_create_physical_replication_slot('replica_slot_1')` trên primary mới. **Cần bổ sung bước này vào runbook promote.**
2. **`postgresql.auto.conf` tích lũy 7 dòng `primary_conninfo`** sau nhiều lần `pg_basebackup -R`, gồm một dòng trỏ về chính node. Giá trị hiệu lực là dòng cuối nên hệ thống vẫn chạy, nhưng đây là bẫy khi copy file. Kiểm tra bằng `show primary_conninfo`.
3. **Cluster thực tế là PostgreSQL 15**, không phải 16. `pg_lsclusters`: cluster 16 `down,binaries_missing`; `/etc/postgresql/16/main/postgresql.conf` lại trỏ `data_directory` vào `/var/lib/postgresql/15/main`. Runbook `promote-and-recovery-runbook.md` đang ghi đường dẫn 16 — **các lệnh đó sẽ thất bại**.
4. **SSH giữa VM không có key**: từ Firewall-A/Log-Monitor sang VM khác trả `Permission denied (publickey)`. Mọi bước "node này kiểm tra node kia" phải chạy từ Windows host dùng `-J`.

## Kết luận

- Các luồng chức năng, phân vùng, database failover/rejoin, negative security và central logging đều có evidence **chụp terminal thật** ngày 17/11, khớp với trạng thái live và khớp với báo cáo DOCX/PPTX.
- Firewall HA đạt bằng **VRRP unicast tự động** (Keepalived), thay thế thao tác Gateway IP Migration thủ công; quy trình thủ công vẫn giữ trong runbook làm rollback.
- GAP-01 (thiếu Keepalived) đã khắc phục và nghiệm thu — nay có ảnh chứng minh trạng thái `active`/`enabled`, không còn là ảnh chụp lúc lỗi.
- **J-02 không còn áp dụng**: rule tạm `FW-ALLOW-SITE-A-JUMP` đã bị gỡ. Giữ J-02 như kết quả lịch sử ngày 10/11, hoặc tái lập rule nếu muốn nghiệm thu lại.
- Tồn tại 4 vấn đề vận hành ghi ở trên, trong đó (1) và (3) nên sửa trong runbook trước buổi demo.
