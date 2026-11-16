# Acceptance Matrix — Site A/B

**Ngày kiểm thử gần nhất:** 2026-11-16  
**Site B owner:** Minh Hùng  
**Site A owner:** Quan Bảo  
**Evidence Site B:** `evidence/minh-hung/20261112-minh-hung-site-b-comprehensive.md`  
**Evidence VRRP:** `evidence/minh-hung/20261113-minh-hung-vrrp-keepalived.md`  
**Ảnh VRRP:** `evidence/minh-hung/images/20261116-minh-hung-vrrp-{1-baseline,2-failover,3-failback,4-db-syslog}.png`  
**Evidence joint Site A/B:** `evidence/quan-bao/20261110-quan-bao-joint-integration.md`

> Matrix này tổng hợp kết quả đã có trong repository. Các mục Site A giữ nguyên theo evidence của Quan Bảo; các mục Site B được chạy lại theo kịch bản `Script/site-b-comprehensive-scenario.md`, sau đó bổ sung chuỗi kiểm thử VRRP unicast ngày 2026-11-16.

| ID | Phạm vi | Tiêu chí nghiệm thu | Kết quả gần nhất | Evidence |
|---|---|---|---|---|
| C-01 | Site A | Transit-A nhận route Site B và ping DB | PASS | `evidence/quan-bao/20261110-quan-bao-joint-integration.md` |
| J-01 | Liên site | Site A đi qua Transit-B vào Log-Monitor | PASS | Joint integration |
| J-02 | Firewall | Site-A jump có rule và log | PASS | Joint integration |
| J-03 | Transit-B | Route DB/MGMT qua Firewall-A, forwarding bật | PASS | Joint integration + SB-01 |
| J-04 | Firewall | nftables active, deny-by-default, VIP gateway | PASS | Joint integration + SB-04/SB-05 |
| J-05 | Management | SSH quản trị qua đường được phép | PASS | Joint integration |
| J-06 | Security | WAN/Transit truy cập DB 5432 bị chặn | PASS | Joint integration + SB-07/SB-08 |
| J-07 | Database | Streaming replication và dữ liệu đồng bộ | PASS — `.12 -> .11 streaming async` sau chuỗi VRRP | Ảnh 4 + SB-10 |
| J-08 | Database | Least privilege: INSERT/UPDATE được, DELETE/DROP bị từ chối | PASS | Joint integration + SB-11/SB-12 |
| J-09 | Database | Promote Replica và ghi dữ liệu khi Primary dừng | PASS | Joint integration + SB-13/SB-14 |
| J-10 | Database | Primary cũ rejoin thành Standby | PASS | Joint integration + SB-15 |
| J-11 | Firewall HA | Dừng Keepalived trên A → B tự nhận đủ 5 VIP, deny policy intact | PASS — VRRP unicast | Ảnh 2 + SB-16/SB-17 |
| J-12 | Firewall HA | Khởi động lại Keepalived trên A → A tự preempt lấy lại 5 VIP | PASS — VRRP unicast | Ảnh 3 + SB-18 |
| J-13 | Monitoring | Central syslog nhận log firewall, listener 514 UDP+TCP | PASS | Ảnh 4 + SB-19/SB-20 |
| GAP-01 | Firewall HA | `keepalived`/VRRP service tồn tại và active trên FW-A/B | RESOLVED — `active`, `enabled`, config validation OK | Ảnh 1/3 |
| A-01 | Site A | `/healthz` trả 200 trên Web-A/Web-B | PASS | `evidence/quan-bao/` |
| A-02 | Site A | HTTPS VIP phân phối round-robin | PASS | `evidence/quan-bao/` |
| A-03 | Site A | Web failover qua VIP | PASS | `evidence/quan-bao/` |
| A-04 | Site A | SSH key-only trên web nodes | PASS | `evidence/quan-bao/` |

## Diễn biến VRRP (2026-11-16)

- **Baseline:** Firewall-A `keepalived=active nftables=active VIP=5` (MASTER); Firewall-B `active/active VIP=0` (BACKUP).
- **Failover:** `19:25:43` dừng Keepalived **chỉ trên Firewall-A** → `19:25:44` Firewall-B vào `MASTER` với `VRRP_Group(VG_FW) Syncing instances to MASTER state`; Firewall-B nhận đủ 5 VIP. Không dùng `ip addr add`.
- **Failback:** `19:26:39` khởi động lại Keepalived trên Firewall-A → `19:26:43` Firewall-A MASTER với 5 VIP (preempt 150 > 100); Firewall-B về BACKUP, 0 VIP.
- **Config validation:** `keepalived_cfg=OK nft_cfg=OK` trên cả hai firewall.
- **Database:** `.12` Primary (`pg_is_in_recovery()=f`), `.11` Standby (`t`), `streaming | async`, slot `replica_slot_1 active=t`.
- **Logging:** rsyslog listen `172.20.50.10:514` trên cả UDP và TCP.

## Kết luận

- Các luồng chức năng, phân vùng, database failover/rejoin, negative security và central logging đều có evidence PASS.
- Firewall HA nay đạt bằng **VRRP unicast tự động** (Keepalived), thay thế thao tác Gateway IP Migration thủ công; quy trình thủ công vẫn được giữ trong runbook làm rollback.
- GAP-01 (thiếu Keepalived) đã được khắc phục và nghiệm thu.
