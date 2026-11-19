# Biên bản kiểm thử VRRP unicast Keepalived — 2026-11-16

**Người thực hiện:** Minh Hùng  
**Phạm vi:** Firewall-A `172.20.50.2`, Firewall-B `172.20.50.3`, DB `.11/.12`, Log-Monitor `.10`  
**Ảnh evidence (chụp từ cửa sổ console thật):**

- [1. Baseline](images/20261116-minh-hung-vrrp-1-baseline.png)
- [2. Failover](images/20261116-minh-hung-vrrp-2-failover.png)
- [3. Failback](images/20261116-minh-hung-vrrp-3-failback.png)
- [4. PostgreSQL + syslog](images/20261116-minh-hung-vrrp-4-db-syslog.png)

**Log đối chiếu:** [20261116-vrrp-evidence-chain.log](logs/20261116-vrrp-evidence-chain.log)

## Kết quả

| # | Hạng mục | Kết quả thực tế | Đánh giá |
|---|---|---|---:|
| 1 | Baseline | fw-a `keepalived=active nftables=active VIP=5`; fw-b `active/active VIP=0` | PASS |
| 2 | Failover | Dừng **chỉ** keepalived trên fw-a; fw-a về `VIP=0`; fw-b tự `VIP=5` với `VG_FW syncing to MASTER`; không dùng `ip addr add` | PASS |
| 3 | Failback | Start keepalived trên fw-a; fw-a về `VIP=5` (preempt 150>100); fw-b về `VIP=0` | PASS |
| 4 | Config validation | fw-a `keepalived_cfg=OK nft_cfg=OK`; fw-b `keepalived_cfg=OK nft_cfg=OK` | PASS |
| 5 | PostgreSQL streaming | `.12` Primary: `172.20.40.11 | streaming | async`, slot `replica_slot_1 active=t`; `.11` Standby: `pg_is_in_recovery()=t` | PASS |
| 6 | Central syslog | Log-Monitor listen `172.20.50.10:514` trên cả UDP và TCP | PASS |

## Trích log chính

```text
Step 2 FAILOVER (19:25:43 -> 19:25:48)
  fw-a keepalived=inactive VIP_COUNT=0
  fw-b VIP_COUNT=5
  19:25:44 (VI_40) Entering MASTER STATE
  19:25:44 VRRP_Group(VG_FW) Syncing instances to MASTER state

Step 3 FAILBACK (19:26:39)
  fw-a VIP_COUNT=5
  19:26:43 VRRP_Group(VG_FW) Syncing instances to MASTER state
  fw-b VIP_COUNT=0

Step 4 DATABASE
  client_addr  | state     | sync_state
  172.20.40.11 | streaming | async
  replica_slot_1 | active=t
  .11 pg_is_in_recovery = t
```

## Kết luận nghiệm thu

VRRP unicast đã thay thế hoàn toàn thao tác chuyển VIP thủ công: dừng Keepalived trên Firewall-A khiến Firewall-B tự nhận đủ 5 gateway VIP, và khởi động lại Firewall-A khiến nó tự preempt lấy lại cả 5. nftables vẫn deny-by-default với 5 rule VRRP protocol 112. Sau chuỗi test, PostgreSQL `.12 → .11` duy trì `streaming | async` và rsyslog tập trung vẫn hoạt động.

Manual Gateway IP Migration trong runbook được giữ làm rollback.
