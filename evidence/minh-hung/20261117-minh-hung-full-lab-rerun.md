# Biên bản chạy lại toàn diện bài lab — Site B — 2026-11-17

- **Người thao tác:** Minh Hùng (Site B)
- **Thời gian:** 2026-11-17, 00:30–02:42 (+07:00), một lần chạy liên tục
- **Phương pháp:** mỗi bước là một phiên SSH thật trên cửa sổ terminal riêng (`mintty`), chạy `bash -x` nên **mỗi dòng lệnh hiển thị là lệnh thật do shell in ra trước khi thực thi**. Ảnh chụp là chụp cửa sổ terminal đó (`PrintWindow`), không dựng lại, không render từ file log.
- **Ảnh:** `images/20261117-minh-hung-*.png` — 34 ảnh
- **Log thô:** `logs/20261117-*.log` — 34 file, mỗi file là transcript đầy đủ của phiên tương ứng
- **Kiểm chứng:** toàn bộ 34 ảnh được OCR (`tesseract`) và đối chiếu; 34/34 có nội dung đọc được, không ảnh rỗng, không trùng lặp nội dung.

> Đây là bộ evidence **thay thế** cho các ảnh chụp ngày 2026-11-10/12/16. Lý do chạy lại: (1) 7 ảnh Site A ngày 10/11 là ảnh render từ file log do Quan Bảo tạo, không phải chụp terminal; (2) rule tạm `FW-ALLOW-SITE-A-JUMP` dùng cho J-02 đã bị gỡ khỏi cả hai firewall nên evidence cũ không còn khớp cấu hình hiện tại; (3) vai trò PostgreSQL đã đảo sau chuỗi promote/rejoin.

---

## 1. Trạng thái đầu và cuối

| Mục | Đầu phiên (00:30) | Cuối phiên (02:32) |
|---|---|---|
| Firewall-A | MASTER, 5 VIP | MASTER, 5 VIP |
| Firewall-B | BACKUP, 0 VIP | BACKUP, 0 VIP |
| PostgreSQL `.12` | Primary | Primary |
| PostgreSQL `.11` | Standby | Standby |
| Replication | streaming async | streaming async, slot active |
| Central syslog | 514 UDP+TCP | 514 UDP+TCP |

Baseline được khôi phục đúng sau toàn bộ chuỗi failover/failback — xem SB-27, SB-28.

---

## 2. Kết quả theo hạng mục

| Ảnh | Nội dung | Kết quả đo được |
|---|---|---|
| **SB-01** | Transit-B baseline | route `172.20.0.0/16` qua `172.20.20.1`, `ip_forward=1`, `ip route get 172.20.40.11` đi qua gateway `.40.1` |
| **SB-02a** | Dịch vụ trên Firewall-A | nftables `active`, keepalived `active` |
| **SB-02b** | Dịch vụ trên Log-Monitor | rsyslog `active`, listener `172.20.50.10:514` UDP + TCP |
| **SB-02c** | Dịch vụ trên `.12` | PostgreSQL `active`, vai trò đọc được từ `pg_is_in_recovery()` |
| **SB-03** | Anti-bypass từ DMZ | DB `5432` chặn, FW SSH `22` chặn, `172.20.50.20:514` chặn; ICMP tới DB vẫn 0% loss (route không hỏng) |
| **SB-04** | nftables deny-by-default | `input`/`forward` policy `drop`; đủ prefix `FW-ALLOW-*` và `FW-DENY-*` |
| **SB-05a** | VIP trên Firewall-A | 5 VIP `.1` trên eth0–eth4 (`VIP_COUNT=5`) |
| **SB-05b** | VIP trên Firewall-B | `VIP_COUNT=0` |
| **SB-06** | GAP-01 đã khắc phục | keepalived `2.2.7`, `active`, `enabled`, `keepalived_cfg_exit=0`, `nft_cfg_exit=0`, healthcheck `exit=0` |
| **SB-07** | Negative probe | `.12:5432` và `.11:5432` đều `exit=124`, FW SSH `exit=124` |
| **SB-08** | Counter + nguồn bị chặn | `FW-DEFAULT-DENY` counter tăng; log ghi `SRC=172.20.20.6` |
| **SB-09** | Log trung tâm | cùng sự kiện `FW-DEFAULT-DENY` xuất hiện trong `/var/log/central/fw-a/kernel.log`; đủ 5 thư mục nguồn |
| **SB-10a** | `.12` Primary | `pg_is_in_recovery=f`, `172.20.40.11 streaming async`, `replica_slot_1 active=t` |
| **SB-10b** | `.11` Standby | `pg_is_in_recovery=t`, wal receiver `streaming` từ `.12` |
| **SB-11** | Least privilege | `app_user` chỉ có `INSERT, SELECT, UPDATE`; INSERT thành công (id=114); DELETE `permission denied`; DROP `must be owner` |
| **SB-12** | Replica nhận dòng | dòng `SB-LEAST-PRIV` đọc được trên `.11` |
| **SB-13** | Baseline trước failover | A `keepalived=active VIP=5`, B `BVIP=0` |
| **SB-14** | Failover (phía A) | stop keepalived trên A → `a_keepalived=inactive a_vip=0` |
| **SB-15** | Failover (phía B) | `fw-b VIP_COUNT=5`, 5 VIP `.1`, journal ghi `VRRP_Group(VG_FW) Syncing instances to MASTER state` + 5 dòng `Entering MASTER STATE` cùng giây |
| **SB-16** | Negative khi B giữ VIP | DB `5432` vẫn `124`, VIP SSH `124`, syslog `514` vẫn `0` (đường hợp lệ không bị ảnh hưởng), ping gateway `.40.1` 0% loss |
| **SB-17** | Failback | start keepalived trên A → `a_keepalived=active a_vip=5`, preempt 150 > 100 |
| **SB-18** | Failback phía B | `fw-b VIP_COUNT=0`, `b_keepalived_cfg_exit=0`, `b_nft_cfg_exit=0` |
| **SB-19** | Dừng Primary | `.12` postgresql `inactive` |
| **SB-20** | Promote `.11` | `pg_promote` trả `t`, `pg_is_in_recovery` từ `t` → `f`, ghi dòng `SB-DB-FAILOVER` thành công (id=148) |
| **SB-21** | Rejoin `.12` | data dir `files_left=0`, `pg_basebackup` 100%, `.12` trở lại `t` |
| **SB-22a** | Sau failover: `.11` Primary | `f`, `.12 streaming async`, slot `active=true` |
| **SB-22b** | Sau failover: `.12` Standby | `t`, `streaming from 172.20.40.11`, dòng `148 \| SB-DB-FAILOVER` đã replicate sang |
| **SB-23** | Cấu hình VRRP phía A | `VG_FW` bọc đủ `VI_10..VI_50`, `state MASTER`, `priority 150` |
| **SB-24** | Cấu hình VRRP phía B | cùng sync group, `state BACKUP`, `priority 100` |
| **SB-26** | Failback DB — rejoin `.11` | `pg_basebackup` 100%, `.11` trả `t` |
| **SB-27** | Baseline DB khôi phục (`.12`) | `f`, `.11 streaming async`, `sent_lsn = replay_lsn = 0/12000060` |
| **SB-28** | Baseline DB khôi phục (`.11`) | `t`, `streaming from 172.20.40.12` |
| **C-01** | Liên site | từ Transit-B: `http://172.20.21.100/healthz` trả **200** (Site A sống), syslog `.50.10:514` mở, DB `.40.11:5432` chặn, route tới `172.20.21.5` đi qua `tailscale0` |

---

## 3. Phát hiện kỹ thuật trong lần chạy này

### 3.1 Replication slot không theo node khi promote

Sau khi promote `.11`, `pg_stat_replication` trên `.11` rỗng và `.12` báo:

```text
FATAL: could not start WAL streaming: ERROR: replication slot "replica_slot_1" does not exist
```

**Nguyên nhân:** physical replication slot là **trạng thái cục bộ của từng node**, không được replicate. `.12` khởi tạo slot `replica_slot_1`, nhưng khi `.11` được promote, slot không tồn tại trên `.11`. Standby cấu hình `primary_slot_name = replica_slot_1` nên retry mãi.

**Khắc phục:** tạo slot trên primary mới.

```sql
select pg_create_physical_replication_slot('replica_slot_1');
```

Sau đó trong vòng ~10 giây: `172.20.40.12 | streaming | async`, slot `active=t`.

**Khuyến nghị:** thêm bước tạo slot vào runbook promote, hoặc dùng `pg_basebackup -R` kèm script tạo slot tự động, hoặc chuyển sang `pg_rewind` + slot do công cụ quản lý. Nếu không, mọi lần promote đều để lại một standby "treo im lặng" — `systemctl is-active postgresql` vẫn `active` nhưng không nhận WAL.

### 3.2 `postgresql.auto.conf` tích lũy `primary_conninfo`

Trên `.12` sau nhiều lần `pg_basebackup -R`, file `postgresql.auto.conf` chứa **7 dòng `primary_conninfo`**, trong đó có dòng trỏ về chính `.12`. Giá trị hiệu lực là dòng cuối (đúng `.11`), nên hệ thống vẫn chạy — nhưng đây là bẫy: thứ tự dòng quyết định, rất dễ sai khi copy file.

**Khuyến nghị:** sau mỗi lần rejoin, kiểm tra `show primary_conninfo` thay vì đọc file, và dọn file về đúng một dòng.

### 3.3 Cluster thực tế là PostgreSQL 15, không phải 16

`pg_lsclusters` cho thấy cluster 16 ở trạng thái `down,binaries_missing`; cluster đang chạy là **15/main**, và `/etc/postgresql/16/main/postgresql.conf` lại trỏ `data_directory` vào `/var/lib/postgresql/15/main`. Runbook `promote-and-recovery-runbook.md` đang ghi đường dẫn `.../16/main` và `/usr/lib/postgresql/16/bin/pg_ctl` — **các lệnh đó sẽ thất bại**.

**Khuyến nghị:** sửa runbook sang 15, hoặc cài đủ binary 16 rồi chuyển cluster đúng cách.

### 3.4 SSH giữa các VM không có key

Từ Firewall-A và từ Log-Monitor, `ssh ops@172.20.50.3` / `ops@172.20.40.12` trả `Permission denied (publickey)`. Key `ops` chỉ có ở chiều từ Windows host vào các VM. Vì vậy mọi bước "từ node X kiểm tra node Y" **phải chạy từ Windows host**, không chạy từ trong VM.

---

## 4. Giới hạn còn lại (không thay đổi so với báo cáo 16/11)

- Chưa đồng bộ conntrack: phiên TCP dài có thể reset khi failover. Cần `conntrackd` nếu muốn zero-downtime.
- Health check chỉ kiểm tra `nftables active` + `ip_forward=1`, không probe đường lên thật.
- Keepalived 2.2.7 từ chối `weight` trên track script trong sync group → health fail sẽ fault cả group và nhả toàn bộ VIP (fail-closed, có chủ ý).
- Slot replication phải tạo tay sau mỗi lần promote (mục 3.1) — đây là **lỗ hổng vận hành mới phát hiện**, chưa có trong báo cáo 16/11.

---

## 5. Đối chiếu với acceptance matrix

Các hạng mục sau nay có bằng chứng chụp terminal thật, thay cho ảnh render hoặc ảnh cũ:

| Mã | Trước đây | Nay |
|---|---|---|
| C-01 | ảnh chụp của Quan Bảo (10/11) | `20261117-minh-hung-C-01-joint-site-a-reachable.png` |
| J-02 | rule tạm `FW-ALLOW-SITE-A-JUMP` đã bị gỡ | **không còn áp dụng** — xem ghi chú dưới |
| J-04 | render từ log | SB-04, SB-05a, SB-05b |
| J-06 | render từ log | SB-03, SB-07, SB-16 |
| J-07 | render từ log | SB-10a, SB-10b, SB-27, SB-28 |
| J-09 | render từ log; ghi chú "pg_promote trả recovery not in progress" | SB-19, SB-20 — lần này `pg_promote` trả `t` và role đổi `t → f` |
| J-10 | render từ log; ghi chú "retry mới thành công" | SB-21, SB-26 — thành công ngay, `pg_basebackup 100%` |
| J-11 | render từ log; RTO ~7 giây (manual) | SB-13/14/15 — VRRP tự động, ~1 giây |
| J-12 | render từ log | SB-17, SB-18 |
| J-13 | ảnh cũ | SB-02b, SB-09 |
| GAP-01 | ảnh chụp trạng thái lỗi (`inactive`, `rc=3`) ngày 12/11 | SB-06 — `active`, `enabled`, config hợp lệ |

### Ghi chú về J-02

Biên bản joint 10/11 ghi J-02 PASS nhờ rule tạm `[FW-ALLOW-SITE-A-JUMP:]` trên Firewall-B. Kiểm tra ngày 17/11: **rule này không còn tồn tại trên cả Firewall-A và Firewall-B** (`grep -c "SITE-A"` = 0). Như vậy J-02 không thể tái hiện ở trạng thái hiện tại.

Hai cách xử lý, cần chọn một:

1. **Giữ J-02 là lịch sử** — ghi rõ "PASS ngày 10/11 với rule tạm, rule đã gỡ sau nghiệm thu". Trung thực và không cần thay đổi hệ thống.
2. **Tái lập J-02** — thêm lại rule tạm, chụp ảnh, rồi gỡ. Có rủi ro để lại rule thừa nếu quên.

Đề nghị chọn cách 1.

---

## 6. Danh mục file

Ảnh (34): `images/20261117-minh-hung-SB-01..SB-28` + `C-01`.

Log (34): `logs/20261117-SB-01..SB-28` + `C-01`, mỗi log bắt đầu bằng header `### EV17-<id> | <slug> | <timestamp> | target=<host>` và kết thúc bằng `END=<timestamp>`.
