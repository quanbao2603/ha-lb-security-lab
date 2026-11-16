# Biên bản kiểm thử toàn diện Site B — 2026-11-12

**Người thực hiện:** Minh Hùng  
**Kịch bản:** `Script/site-b-comprehensive-scenario.md`  
**Phạm vi:** Transit-B, Firewall-A/B, DB-Primary/Replica, Log-Monitor  
**Raw output:** `evidence/minh-hung/logs/20261112-*.log`  
**Ảnh evidence:** `evidence/minh-hung/images/20261112-minh-hung-sb*.png`

## 1. Ghi chú vận hành

- VM đã được bật headless bằng `vmrun`; truy cập DMZ/DB dùng ProxyJump qua `Log-Monitor` (`172.20.50.10`).
- VM đã được dời vào `vms/minh-hung/`; tạo junction cục bộ `D:\Lab\vms` để các linked clone còn tham chiếu đường dẫn cũ vẫn hoạt động.
- Trước pha DB, đã chuẩn hóa vai trò do trạng thái trước đó là `.12=Primary`, `.11=Standby`: dừng `.12`, promote `.11`, tạo lại slot `replica_slot_1`, rejoin `.12` bằng `pg_basebackup`.
- Trong lần chạy 2026-11-12, firewall HA được thực hiện bằng Gateway IP Migration thủ công và `keepalived` chưa được cài. Ngày 2026-11-13 → 2026-11-16, Keepalived 2.2.7 với VRRP unicast đã được triển khai và nghiệm thu; chi tiết tại [`20261113-minh-hung-vrrp-keepalived.md`](20261113-minh-hung-vrrp-keepalived.md) với ảnh `images/20261116-minh-hung-vrrp-{1..4}*.png`. Quy trình thủ công vẫn được giữ trong runbook làm rollback.
- Sau SB-15, kiểm tra hậu nghiệm phát hiện `.11` chưa stream vì `.12` (Primary mới) thiếu slot `replica_slot_1`; journal ghi rõ `replication slot "replica_slot_1" does not exist`. Đã tạo slot trên `.12`, sau đó xác nhận `.12 -> .11` là `streaming | async` và receiver `.11` là `streaming`. Raw trace được nối vào `logs/20261112-sb00-role-normalization.log`.
- Mật khẩu `DemoPass123!` chỉ xuất hiện trong lệnh demo của kịch bản; không đưa mật khẩu thật hoặc private key vào evidence.

## 2. Kết quả tổng hợp

| ID | Hạng mục | Kết quả | Evidence |
|---|---|---|---|
| SB-01 | Baseline Transit-B: route, forwarding, Tailscale | PASS — route `172.20.0.0/16` qua `172.20.20.1`, `ip_forward=1`, Tailscale online | [Ảnh](images/20261112-minh-hung-sb01-transit-b-baseline.png), [log](logs/20261112-sb01-transit-b-baseline.log) |
| SB-02 | Dịch vụ nền trên FW-A, Log-Monitor, DB-Primary | PASS — nftables/rsyslog/PostgreSQL đúng node đều active | [Ảnh](images/20261112-minh-hung-sb02-services-active.png), logs `sb02a/b/c` |
| SB-03 | Anti-bypass từ Transit-B | PASS — `db_exit=124`, `ssh_exit=124`, ping DB `0% packet loss` | [Ảnh](images/20261112-minh-hung-sb03-anti-bypass-probes.png), [log](logs/20261112-sb03-anti-bypass-probes.log) |
| SB-04 | Firewall-A deny-by-default và FW-* prefixes | PASS — policy drop, prefix deny/allow, địa chỉ zone đầy đủ | [Ảnh](images/20261112-minh-hung-sb04-fw-a-ruleset.png), [log](logs/20261112-sb04-fw-a-ruleset.log) |
| SB-05 | VIP gateway placement | PASS — 5 VIP `.1` trên Firewall-A, không có trên Firewall-B | [Ảnh](images/20261112-minh-hung-sb05-vip-placement.png), logs `sb05a/b` |
| SB-06 | Keepalived gap (trạng thái lịch sử 2026-11-12) | GAP tại thời điểm chạy — cả hai node trả `inactive`, `rc=3`; **đã khắc phục ngày 2026-11-13** và nghiệm thu lại 2026-11-16 | [Ảnh](images/20261112-minh-hung-sb06-keepalived-gap.png), logs `sb06a/b` |
| SB-07 | Negative probes | PASS — DB 5432 và SSH Firewall-A đều timeout `124` | [Ảnh](images/20261112-minh-hung-sb07-negative-probes.png), [log](logs/20261112-sb07-negative-probes.log) |
| SB-08 | Firewall-A deny log/counter | PASS — có `FW-DEFAULT-DENY` tới DB và `FW-DENY-INPUT-DEFAULT` tới SSH | [Ảnh](images/20261112-minh-hung-sb08-fw-a-deny-log.png), [log](logs/20261112-sb08-fw-a-deny-log.log) |
| SB-09 | Central deny log | PASS — Log-Monitor có thư mục central và log cùng nguồn `SRC=172.20.20.6` | [Ảnh](images/20261112-minh-hung-sb09-central-deny-log.png), [log](logs/20261112-sb09-central-deny-log.log) |
| SB-10 | PostgreSQL replication sync | PASS — `.11=f`, `.12=t`, ba dòng dữ liệu mới nhất giống nhau | [Ảnh](images/20261112-minh-hung-sb10-replication-sync.png), logs `sb10a/b` |
| SB-11 | Least privilege | PASS — INSERT trả id `77`, DELETE bị `permission denied` | [Ảnh](images/20261112-minh-hung-sb11-least-privilege.png), [log](logs/20261112-sb11-least-privilege.log) |
| SB-12 | Replica nhận dòng mới | PASS — Replica trả dòng `77 | SB-LEAST-PRIV` | [Ảnh](images/20261112-minh-hung-sb12-replica-received-row.png), [log](logs/20261112-sb12-replica-received-row.log) |
| SB-13 | Dừng DB-Primary | PASS — PostgreSQL `.11` inactive trước promote | [Ảnh](images/20261112-minh-hung-sb13-primary-stopped.png), [log](logs/20261112-sb13-primary-stopped.log) |
| SB-14 | Promote DB-Replica và ghi dữ liệu | PASS — `pg_promote=t`, recovery `f`, INSERT `SB-FAILOVER` trả id `109` | [Ảnh](images/20261112-minh-hung-sb14-replica-promoted.png), [log](logs/20261112-sb14-replica-promoted.log) |
| SB-15 | Rejoin Primary cũ thành Standby | PASS — data dir rỗng, `pg_basebackup 100%`, `.11` trả `t` | [Ảnh](images/20261112-minh-hung-sb15-primary-rejoined.png), [log](logs/20261112-sb15-primary-rejoined.log) |
| SB-16 | VIP chuyển sang Firewall-B | PASS — lần chạy 2026-11-12 dùng manual Gateway IP Migration; từ 2026-11-16 chuyển VIP tự động qua VRRP unicast | [Ảnh](images/20261112-minh-hung-sb16-vip-on-fw-b.png), [log](logs/20261112-sb16-fw-manual-migration.log) |
| SB-17 | Negative probe khi Firewall-B giữ VIP | PASS — DB/SSH vẫn timeout và Firewall-B ghi deny log | [Ảnh](images/20261112-minh-hung-sb17-negative-during-failover.png), logs `sb17a/b` |
| SB-18 | Failback VIP về Firewall-A | PASS — VIP `.1` trở lại Firewall-A; từ 2026-11-16 failback tự động do preemption (priority 150 > 100) | [Ảnh](images/20261112-minh-hung-sb18-vip-failback.png), [log](logs/20261112-sb18-vip-failback.log) |
| SB-19 | Central logging | PASS — rsyslog active, `172.20.50.10:514 LISTEN`, đủ 5 thư mục nguồn, log FW-A mới | [Ảnh](images/20261112-minh-hung-sb19-central-logging.png), [log](logs/20261112-sb19-central-logging.log) |
| SB-20 | Final state | PASS — `.11=t`, `.12=f`, dữ liệu đồng bộ, VIP Firewall-A, central log tiếp tục nhận | [Ảnh](images/20261112-minh-hung-sb20-final-state.png), logs `sb20a/b/c` |

## 3. Trạng thái cuối

- `DB-Primary` `172.20.40.11`: Standby, `pg_is_in_recovery() = t`.
- `DB-Replica` `172.20.40.12`: Primary, `pg_is_in_recovery() = f`.
- Streaming sau rejoin hoạt động qua `replica_slot_1`.
- Firewall-A giữ 5 gateway VIP `.1`; Firewall-B không giữ VIP.
- Log-Monitor nhận log tập trung từ `db-primary`, `db-replica`, `fw-a`, `fw-b`, `transit-b`.
- Firewall HA: từ 2026-11-16 chạy **VRRP unicast tự động** bằng Keepalived 2.2.7 (`active`, `enabled` trên cả hai firewall). Baseline A=5 VIP/B=0; failover B=5 VIP; failback A=5 VIP. Chi tiết: [`20261113-minh-hung-vrrp-keepalived.md`](20261113-minh-hung-vrrp-keepalived.md).
- GAP-01 (thiếu `keepalived`) đã khắc phục; quy trình Gateway IP Migration thủ công chỉ còn là rollback.
