# KỊCH BẢN BÁO CÁO — SITE B HA & SECURITY LAB

**Người trình bày:** Minh Hùng (Site B)
**Thời lượng chuẩn:** 20 phút (bản 10 phút ở mục 7)
**Ngày soạn:** 2026-11-17 — mọi lệnh dưới đây đã chạy thật trên hệ thống live ngày 17/11/2026.

> Đây là kịch bản **báo cáo + biểu diễn trực tiếp**. Slide là phần dẫn dắt, demo là phần chứng minh.
> Nguyên tắc: **mỗi điều tôi nói đều có một lệnh chứng minh được ngay trên màn hình.**

---

## 0. Chuẩn bị trước giờ báo cáo (T−15 phút)

### 0.1 Mở sẵn 4 cửa sổ terminal

| Cửa sổ | Đăng nhập | Dùng cho |
|---|---|---|
| **T1** | `ssh ops@172.20.50.2` (Firewall-A) | Baseline, failover, failback |
| **T2** | `ssh ops@172.20.50.3` (Firewall-B) | Đón VIP khi failover |
| **T3** | `ssh ops@172.20.50.10` (Log-Monitor) | `tail -f` log tập trung |
| **T4** | `ssh -J ops@172.20.50.10 ops@172.20.40.12` (DB Primary) | Replication, least privilege |

Mở sẵn cả 4 **trước** khi bắt đầu để không phải gõ mật khẩu/không bị hỏi host key giữa lúc demo. Phóng font terminal lên ≥16pt.

### 0.2 Kiểm tra baseline (bắt buộc)

```bash
for h in 172.20.50.2 172.20.50.3; do
  ssh -o ConnectTimeout=5 ops@$h \
    'printf "%s keepalived=%s nftables=%s VIP=%s\n" "$(hostname)" \
     "$(systemctl is-active keepalived)" "$(systemctl is-active nftables)" \
     "$(ip -4 addr show | grep -c secondary)"'
done
```

**Phải ra đúng 2 dòng này** (đã kiểm chứng 17/11):

```text
fw-a keepalived=active nftables=active VIP=5
fw-b keepalived=active nftables=active VIP=0
```

Nếu lệch (ví dụ A=0/B=5 do lần demo trước chưa khôi phục):

```bash
ssh ops@172.20.50.2 'sudo systemctl start keepalived'
sleep 5
# chạy lại vòng lặp kiểm tra ở trên
```

### 0.3 Kiểm tra 6 VM đang chạy

```powershell
& "C:\Program Files\VMware\VMware Workstation\vmrun.exe" list
```

Phải thấy đủ 6: Firewall-A, Firewall-B, Transit-B, DB-Primary, DB-Replica, Log-Monitor.

### 0.4 Mở sẵn tài liệu

- `docs/minh-hung/20261116-bao-cao-nghiem-thu-lab-ha-security.pptx` (13 slide)
- `docs/minh-hung/20261116-bao-cao-nghiem-thu-lab-ha-security.docx` (6 trang) — chỉ mở khi được hỏi chi tiết
- Thư mục `evidence/minh-hung/images/` — mở 4 ảnh `20261116-minh-hung-vrrp-{1..4}` để sẵn nếu cần đối chiếu

### 0.5 Hai điều tuyệt đối tránh

1. **Không** chạy `ssh ops@172.20.40.12` hay `ssh ops@172.20.20.6` trực tiếp từ Windows — máy host chỉ có route tới VMnet15 (`172.20.50.0/24`), hai mạng kia sẽ **timeout**. Luôn dùng `-J ops@172.20.50.10`.
2. **Không** đăng nhập vào Log-Monitor rồi SSH tiếp sang DB — key của bạn không nằm trên Log-Monitor nên sẽ bị `Permission denied (publickey)`. `-J` chỉ mở đường ống TCP, xác thực vẫn là key của bạn ở máy Windows, nên chạy từ Windows mới được.

---

## 1. Dàn bài 20 phút

| Thời điểm | Nội dung | Slide |
|---|---|---|
| 0:00 – 2:00 | Mở đầu + kết luận đi trước | 1–2 |
| 2:00 – 5:00 | Kiến trúc 2 site / 5 vùng | 3 |
| 5:00 – 7:00 | Kiểm soát bảo mật nftables | 4 |
| 7:00 – 8:30 | Ma trận nghiệm thu 19 hạng mục | 5 |
| 8:30 – 9:30 | Bối cảnh: trước đây chuyển VIP thủ công | 6 |
| 9:30 – 10:00 | Giải pháp: VRRP unicast + sync group | 7 |
| **10:00 – 16:00** | **DEMO TRỰC TIẾP 4 màn** | (thay slide 8–11) |
| 16:00 – 18:00 | Rủi ro còn lại, trung thực | 12 |
| 18:00 – 20:00 | Kết luận, đề nghị nghiệm thu | 13 |

---

## 2. Lời thoại theo slide

### Slide 1 — Tiêu đề (30 giây)

> "Em là Minh Hùng, phụ trách Site B: hai firewall HA, hai node PostgreSQL, một Log-Monitor và Transit-B. Hôm nay em báo cáo kết quả nghiệm thu, và em sẽ **làm lại toàn bộ bằng chứng ngay trước mặt thầy/các bạn** chứ không chỉ trình bày ảnh chụp."

### Slide 2 — Kết luận đi trước (90 giây)

> "Kết luận trước để mọi người có khung theo dõi: **19 hạng mục nghiệm thu — 18 PASS, 1 RESOLVED, 0 GAP mở.** Trong đó GAP-01 là lỗi thiếu Keepalived, đã khắc phục và nghiệm thu lại.
> Đi kèm là 31 ảnh bằng chứng và 34 file log thô. Điểm em muốn nhấn mạnh: ba lớp bằng chứng — ảnh console có output thật, log thô, và trạng thái live — **khớp nhau**. Em sẽ chứng minh lớp thứ ba ngay bây giờ."

### Slide 3 — Kiến trúc (3 phút)

Nói theo sơ đồ, nhấn 2 ý:

> "Năm vùng mạng: WAN-LAB `.10`, DMZ/Transit `.20`, APP `.30`, DATABASE `.40`, MANAGEMENT `.50`. Toàn bộ lưu lượng liên vùng đi qua **một** điểm kiểm soát là cặp Firewall-A/B — Web và DB **không** cài Tailscale trực tiếp, nên không có đường bypass."
> "Gateway của mọi vùng là VIP `.1` — và đây chính là điểm mấu chốt: **5 VIP phải di chuyển cùng nhau**, không được di chuyển lẻ."

Nếu bị hỏi vì sao không cho DB dùng Tailscale: *"để DB không thể bị với tới từ ngoài firewall; mọi đường vào DB đều phải qua `.40.1`."*

### Slide 4 — Bảo mật nftables (2 phút)

> "Chính sách là **deny-by-default** ở cả chain input và forward. Mỗi rule cho phép đều gắn một log prefix có cấu trúc — `FW-ALLOW-SYSLOG`, `FW-ALLOW-WEB-DB`, `FW-DENY-WAN-DIRECT:DB` — để log không chỉ là 'có traffic' mà đọc được **ý định** của rule."
> "Em xin đọc nguyên văn 5 nhóm prefix đang nằm trên firewall: `FW-DENY-SPOOF` (6 rule, chống giả mạo nguồn theo từng interface), `FW-DENY-INVALID`, `FW-DENY-WAN-SSH`, `FW-DENY-INPUT-DEFAULT`, `FW-DEFAULT-DENY`."

Tránh nói "không thể bypass" tuyệt đối — nói *"không có đường bypass đã biết, và mọi gói bị chặn đều để lại log."*

### Slide 5 — Ma trận nghiệm thu (90 giây)

> "19 hạng mục chia 4 nhóm: liên site (J-01…J-05), bảo mật (J-06…J-08), database HA (J-09, J-10), firewall HA (J-11, J-12), monitoring (J-13), cộng 4 hạng mục Site A của bạn Quan Bảo và GAP-01.
> Điểm đáng chú ý: **J-11 và J-12 trước đây là GAP** — chuyển VIP thủ công, không tự động. Đó là phần em sẽ demo."

### Slide 6 — Bối cảnh (1 phút)

> "Cách làm cũ: gỡ VIP `.1` khỏi Firewall-A bằng tay từng interface, rồi gán sang B. Vấn đề không phải là gõ nhiều — mà là **trong lúc gõ, một phần mạng mất gateway** và không có gì đảm bảo 5 VIP đi cùng nhau. Nếu gỡ được 3/5 thì hệ thống ở trạng thái nửa vời, tệ hơn là chết hẳn."

### Slide 7 — Giải pháp VRRP unicast (30 giây) → chuyển ngay sang demo

> "Giải pháp: Keepalived 2.2.7, **VRRP unicast** — vì 5 mạng host-only của VMware không chuyển được multicast — với **một sync group `VG_FW`** bọc cả 5 instance `VI_10`…`VI_50`. A priority 150 MASTER, B priority 100 BACKUP.
> Một chi tiết kỹ thuật em muốn nói rõ vì nó hay bị hiểu sai: Keepalived 2.2.7 **từ chối** `weight` trên track script nằm trong sync group. Nên khi health check fail, **cả group bị fault và nhả toàn bộ VIP** — fail-closed, thà mất dịch vụ ngắn còn hơn giữ VIP trên một node đang hỏng.
> Giờ em chứng minh."

---

## 3. DEMO TRỰC TIẾP — 4 màn (6 phút)

> Nguyên tắc dẫn dắt: nói **kỳ vọng trước**, rồi mới chạy lệnh. Người xem sẽ tin con số vì họ đã biết phải chờ gì.

### Màn 1 — Baseline: A giữ 5 VIP, B giữ 0 (1 phút)

**T1 (Firewall-A)** — nói trước: *"Em chờ A có 5 dòng `secondary` và B có 0."*

```bash
hostname
systemctl is-active keepalived nftables
ip -4 addr show | grep secondary
```

Kết quả thật:

```text
fw-a
active
active
    inet 172.20.10.1/24 scope global secondary eth0
    inet 172.20.20.1/24 scope global secondary eth1
    inet 172.20.30.1/24 scope global secondary eth2
    inet 172.20.40.1/24 scope global secondary eth3
    inet 172.20.50.1/24 scope global secondary eth4
```

**T2 (Firewall-B)**:

```bash
hostname
systemctl is-active keepalived nftables
ip -4 addr show | grep -c secondary
```

Kết quả thật: `fw-b` / `active` / `active` / `0`

Thêm 1 câu chốt: *"B đang chạy Keepalived nhưng ở vai BACKUP — nó sẵn sàng, chỉ chưa sở hữu VIP."*

### Màn 2 — Failover: B nhận đủ 5 VIP trong ~1 giây (2 phút) ⭐

Đây là màn quan trọng nhất. **Chuẩn bị T2 hiện sẵn `journalctl -f` trước khi bấm dừng trên T1**, để người xem thấy log nhảy realtime.

**T2 trước** (để chạy nền, chỉ hiện log):

```bash
sudo journalctl -u keepalived -f
```

**T1** — nói: *"Em dừng Keepalived **chỉ trên A**. Kỳ vọng: A về 0 VIP, B lên 5 VIP, và B ghi được dòng `VRRP_Group(VG_FW) Syncing instances to MASTER` — tức là 5 VIP đi cùng một lệnh, không phải 5 lần `ip addr add`."*

```bash
sudo systemctl stop keepalived
sleep 3
systemctl is-active keepalived
ip -4 addr show | grep -c secondary
```

**T1 kết quả thật:** `inactive` / `0`

**T2** — Ctrl-C khỏi `journalctl -f`, rồi:

```bash
ip -4 addr show | grep secondary
```

Kết quả thật (đủ 5 dòng `.1` trên eth0…eth4), kèm log:

```text
(VI_30) Entering MASTER STATE
VRRP_Group(VG_FW) Syncing instances to MASTER state
(VI_10) Entering MASTER STATE
(VI_20) Entering MASTER STATE
(VI_40) Entering MASTER STATE
(VI_50) Entering MASTER STATE
```

Câu chốt: *"Thời gian từ lúc dừng đến lúc B đủ 5 VIP: khoảng 1 giây. Không có thao tác tay nào."*

### Màn 3 — Failback: A preempt lấy lại (1 phút)

**T1** — nói: *"Bật lại A. A priority 150 > B 100 nên A phải tự preempt, không cần chạm vào B."*

```bash
sudo systemctl start keepalived
sleep 5
systemctl is-active keepalived
ip -4 addr show | grep -c secondary
```

Kết quả thật: `active` / `5`

**T2**:

```bash
ip -4 addr show | grep -c secondary
```

Kết quả thật: `0`

Chốt bằng kiểm tra cấu hình — đây là câu trả lời cho "sao biết cấu hình còn đúng sau khi failover":

**T1**: `sudo keepalived -t -f /etc/keepalived/keepalived.conf; echo "keepalived_cfg_exit=$?"`
**T1**: `sudo nft -c -f /etc/nftables.conf; echo "nft_cfg_exit=$?"`

Kết quả thật: cả hai `exit=0`.

> Nếu chỉ có 5 phút: chạy Màn 2 rồi Màn 3, bỏ Màn 1 bằng cách nói miệng "baseline A=5/B=0" và chỉ vào slide 8.

### Màn 4 — Database + log tập trung (2 phút)

**T4 (DB Primary qua jump)**:

```bash
hostname
sudo -n -u postgres psql -tAc "select pg_is_in_recovery()"
sudo -n -u postgres psql -x -c "select client_addr, state, sync_state from pg_stat_replication"
```

Kết quả thật: `db-replica` / `f` / `client_addr=172.20.40.11, state=streaming, sync_state=async`

Nói rõ vì sao `.12` là Primary: *"sau chuỗi test promote/rejoin ngày 12/11, `.12` giữ vai Primary và `.11` là Standby. Đây là trạng thái em ghi trong báo cáo, không phải nhầm."*

**Least privilege** — vẫn trên T4:

```bash
sudo -n -u postgres psql -d ha_lab_db
```

Trong psql:

```sql
SET ROLE app_user;
INSERT INTO health_checks(node_name,status) VALUES ('DEMO-01','OK') RETURNING id;
DELETE FROM health_checks WHERE node_name='DEMO-01';
DROP TABLE health_checks;
RESET ROLE;
DELETE FROM health_checks WHERE node_name='DEMO-01';
\q
```

Kết quả thật:
- `INSERT` → trả về id, `INSERT 0 1` ✅
- `DELETE` → `ERROR: permission denied for table health_checks` ✅
- `DROP TABLE` → `ERROR: must be owner of table health_checks` ✅
- `RESET ROLE` + `DELETE` cuối → `DELETE 1` (dọn dữ liệu demo bằng quyền postgres)

Nói: *"`app_user` chỉ có INSERT/SELECT/UPDATE — không có DELETE, không có DROP. Và em vừa dọn sạch dòng demo."*

### Màn 5 — Chặn + log về trung tâm (1 phút) ⭐

Màn này ăn điểm nhất vì chứng minh **đồng thời** chặn và quan sát được.

**T3 (Log-Monitor)** — bật trước:

```bash
sudo tail -f /var/log/central/fw-a/kernel.log
```

**T5 (Transit-B, mở sẵn từ trước)**:

```bash
ssh -J ops@172.20.50.10 ops@172.20.20.6
```

Trên T5, nói: *"Đứng từ DMZ, thử vào PostgreSQL. Kỳ vọng: bị chặn, và trên Log-Monitor hiện một dòng `FW-DEFAULT-DENY` với đúng SRC/DST/DPT."*

```bash
timeout 4 bash -c "cat </dev/null >/dev/tcp/172.20.40.11/5432" || echo BLOCKED
```

Kết quả thật: `BLOCKED`, và trong 1–2 giây T3 hiện:

```text
fw-a kernel: [FW-DEFAULT-DENY:] IN=eth1 OUT=eth3 ... SRC=172.20.20.6 DST=172.20.40.11 ... PROTO=TCP SPT=56078 DPT=5432
```

Chốt thêm 1 lệnh anti-bypass trên T5:

```bash
timeout 4 bash -c "echo >/dev/tcp/172.20.50.20/514" || echo "BYPASS BLOCKED"
```

Kết quả thật: `BYPASS BLOCKED` (chặn tại `transit_filter` của Transit-B).

Nói: *"`.50.20` là một địa chỉ không hề tồn tại — mục đích là thử lách firewall sang Management. Transit-B tự chặn ở `TRANSIT-B-BYPASS-DROP`."*

> Nếu T5 không kịp mở: bỏ màn này, chỉ chiếu ảnh SB-07 và SB-09. Nhưng đừng bỏ **Màn 2**.

---

## 4. Slide 12 — Rủi ro còn lại (2 phút)

Trình bày trung thực, không giấu. Đây là phần tạo uy tín.

> "Ba điểm hạn chế, em ghi rõ trong báo cáo chứ không bỏ qua:
> **Một**, chưa đồng bộ conntrack — phiên TCP dài có thể reset khi failover. Giải pháp nếu cần zero-downtime là `conntrackd`.
> **Hai**, health check chỉ kiểm tra nftables active và `ip_forward=1`, **không** kiểm tra đường lên thật. Nên nó bắt được lỗi cục bộ, không bắt được lỗi upstream.
> **Ba**, vì Keepalived 2.2.7 không cho `weight` trong sync group, một health check fail sẽ **nhả toàn bộ VIP** thay vì hạ priority. Đây là đánh đổi có chủ ý: fail-closed, không cho phép trạng thái nửa vời."

Nếu bị hỏi "vậy có đạt HA không?": *"Đạt ở mức automatic failover cho VIP với RTO ~1 giây, và fail-closed khi node hỏng. Không tuyên bố zero-downtime cho phiên TCP dài — điều đó cần conntrackd."*

---

## 5. Slide 13 — Kết luận (2 phút)

> "Tóm lại 4 điểm:
> **Phân vùng:** 5 zone, deny-by-default, không có đường bypass đã biết, mọi chặn đều có log.
> **Firewall HA:** VRRP unicast + sync group, 5 VIP di chuyển nguyên khối, ~1 giây, tự preempt khi node chính trở lại.
> **Database:** streaming async `.12 → .11`, promote/rejoin đã nghiệm thu, least privilege chứng minh được DELETE/DROP bị từ chối.
> **Observability:** syslog tập trung 514 UDP+TCP, log tách theo hostname, có structured prefix.
> Em đề nghị nghiệm thu. Bằng chứng nằm trong repo `main`, commit `eb278d7`, và trạng thái live vừa demo khớp với báo cáo."

---

## 6. Phòng thủ khi sự cố giữa demo

| Triệu chứng | Nguyên nhân thường gặp | Xử lý tại chỗ |
|---|---|---|
| `ssh: connect to host ... timed out` tới `.40.x` / `.20.x` | Quên `-J`, hoặc host không có route | Dùng `ssh -J ops@172.20.50.10 ops@<ip>` |
| `Permission denied (publickey)` khi SSH từ Log-Monitor sang DB | Key không có trên Log-Monitor | Luôn chạy `-J` **từ Windows**, đừng SSH hai bước |
| Dừng keepalived trên A mà B vẫn 0 VIP | B chưa chạy, hoặc bị chặn proto 112 | `ssh ops@172.20.50.3 'sudo systemctl restart keepalived; sudo journalctl -u keepalived -n 20 --no-pager'` |
| Failback không xảy ra, A vẫn 0 VIP | A chưa `start`, hoặc preempt bị tắt | `sudo systemctl start keepalived; sleep 5; ip -4 addr show \| grep -c secondary` |
| Không thấy log trên T3 | T3 đang tail file khác, hoặc chưa có gói mới | Ctrl-C, `sudo ls /var/log/central/`, tail lại đúng `fw-a/kernel.log`, rồi bắn lại probe |
| psql báo `must be owner` khi bạn định dọn dòng demo | Đang ở `SET ROLE app_user` | `RESET ROLE;` rồi `DELETE` lại |
| Bị hỏi host key | Terminal mới | Gõ `yes`; hoặc mở sẵn 4 terminal từ T−15 |

**Nếu hệ thống sập hoàn toàn giữa demo:** dừng demo, chuyển sang ảnh bằng chứng (slide 8–11 + `evidence/minh-hung/images/`), nói rõ *"hệ thống lab đang gặp sự cố, bằng chứng đã thu thập trong một lần chạy liên tục ngày 16/11"*. Không diễn giải sự cố thành kết quả.

---

## 7. Bản rút gọn 10 phút

| Phút | Nội dung |
|---|---|
| 0–1 | Slide 1–2: kết luận 19 hạng mục |
| 1–3 | Slide 3: kiến trúc + 5 VIP phải đi cùng nhau |
| 3–4 | Slide 7: VRRP unicast, sync group, bỏ weight |
| **4–8** | **Màn 2 (failover) + Màn 3 (failback)** |
| 8–9 | Màn 5: chặn từ DMZ + log hiện trên Log-Monitor |
| 9–10 | Slide 12–13: 3 rủi ro + đề nghị nghiệm thu |

Bỏ: slide 4, 5, 6, và Màn 1, Màn 4 (nói miệng 1 câu: DB `.12` primary streaming sang `.11`, least privilege đã chứng minh).

---

## 8. Câu hỏi thường gặp — trả lời sẵn

**Vì sao unicast mà không multicast?**
> "Năm mạng host-only của VMware trong lab không chuyển VRRP multicast. Unicast peer chỉ định đích danh `.2`/`.3` nên đi được, và firewall chỉ mở `ip protocol vrrp` từ đúng IP peer."

**Vì sao một sync group thay vì 5 instance độc lập?**
> "Vì gateway là một khái niệm nguyên khối. Nếu `VI_30` di chuyển mà `VI_40` không, host mất gateway mặc định nhưng vẫn vào được một phần mạng — trạng thái nửa vời khó debug hơn downtime."

**Track script fail thì chuyện gì xảy ra?**
> "Toàn bộ `VG_FW` fault, cả 5 VIP được nhả. Không hạ priority vì Keepalived 2.2.7 từ chối `weight` trên script trong sync group. Em chọn fail-closed."

**Failover mất bao lâu?**
> "VIP chuyển trong khoảng 1 giây, đo được trên lần chạy thật. Đó là RTO cho VIP, không phải RTO cho phiên TCP đang mở."

**Sao `.12` là Primary mà tên VM là DB-Replica?**
> "Tên VM giữ từ thiết kế ban đầu. Sau chuỗi test promote ngày 12/11, vai trò thực tế đảo: `.12` Primary, `.11` Standby. Báo cáo và ma trận ghi theo vai trò thực tế; tên file VM không đổi để khỏi phá snapshot."

**Log có bị mất khi firewall chết?**
> "Có — hàng đợi syslog cục bộ trên node chết sẽ mất phần chưa gửi. Đó là lý do em ghi 'log tập trung' chứ không ghi 'log bất khả thất'."

---

## 9. Sau khi kết thúc

```bash
# 1. Khôi phục baseline và xác nhận
for h in 172.20.50.2 172.20.50.3; do
  ssh -o ConnectTimeout=5 ops@$h \
    'printf "%s VIP=%s\n" "$(hostname)" "$(ip -4 addr show | grep -c secondary)"'
done
# Kỳ vọng: fw-a VIP=5 / fw-b VIP=0
```

```bash
# 2. Dọn dòng demo nếu còn sót
ssh -J ops@172.20.50.10 ops@172.20.40.12 \
  "sudo -n -u postgres psql -d ha_lab_db -tAc \"select count(*) from health_checks where node_name like 'DEMO%'\""
# Kỳ vọng: 0
```

3. Tắt `tail -f` ở T3.
4. Ghi lại phiên: thời gian, ai dự, câu hỏi chưa trả lời được, việc cần bổ sung.

---

## 10. Việc nên làm trước buổi báo cáo (không bắt buộc, nhưng nên)

- **`.gitignore`:** hiện `git status` đang có `vms/` (21 GB), `isos/` (253 MB) và file `VMware-Workstation-Full-*.exe` (268 MB) untracked. Nếu ai đó yêu cầu `git status` tại buổi demo, danh sách sẽ rất bẩn. Thêm 3 dòng `vms/`, `isos/`, `*.exe` là đủ.
- **`manual-demo-guide.md` đã lỗi thời** (soạn 8/11): ghi sai DB-Primary là `.11`, dùng SSH trực tiếp tới `.40.x`/`.20.x` (sẽ timeout), và không có phần VRRP. **Không dùng file đó để demo.** Kịch bản này thay thế nó.
