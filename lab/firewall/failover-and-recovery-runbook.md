# Runbook: Sao lưu, Khôi phục & Chuyển đổi Dự phòng Firewall (Firewall-A / Firewall-B)

> **Phụ trách:** Minh Hùng  
> **Áp dụng cho:** `Firewall-A` (Active chính) & `Firewall-B` (Standby / Dự phòng)  
> **File cấu hình chuẩn:** `configs/firewall/nftables-firewall.conf`  
> **Mục tiêu RTO (Recovery Time Objective):** `< 2 phút` trong kịch bản chuyển đổi chuẩn của lab.

---

## 1. Mô hình Vận hành Firewall theo Profile RAM trên VMware Workstation

Để tuân thủ nguyên tắc không bật đồng thời toàn bộ 11 VM gây quá tải RAM:
- **Trạng thái bình thường (Baseline):** `Firewall-A` bật và nắm giữ các IP Gateway (`.1`) của tất cả các vùng mạng (`172.20.10.1`, `172.20.20.1`, `172.20.30.1`, `172.20.40.1`, `172.20.50.1`). `Firewall-B` đã được cấu hình sẵn, đồng bộ file `nftables-firewall.conf` và chụp snapshot sạch (`day-1-clean` / `fw-ready`), có thể ở trạng thái Warm-Standby (IP quản trị `.3`) hoặc Cold-Standby (tắt tạm thời để nhường RAM).
- **Trạng thái sự cố (Failover):** Khi `Firewall-A` gặp sự cố hoặc bị cô lập theo kịch bản kiểm thử Ngày 5, `Firewall-B` được kích hoạt để tiếp nhận các IP Gateway (`.1`) và toàn bộ bảng rule `nftables`.

| Tham số | `Firewall-A` (Primary) | `Firewall-B` (Standby) | Gateway IP đang phục vụ (Active) |
|---|---|---|---|
| **WAN-LAB (`eth0`)** | `172.20.10.2/24` | `172.20.10.3/24` | `172.20.10.1/24` |
| **DMZ (`eth1`)** | `172.20.20.2/24` | `172.20.20.3/24` | `172.20.20.1/24` |
| **APP (`eth2`)** | `172.20.30.2/24` | `172.20.30.3/24` | `172.20.30.1/24` |
| **DATABASE (`eth3`)** | `172.20.40.2/24` | `172.20.40.3/24` | `172.20.40.1/24` |
| **MGMT (`eth4`)** | `172.20.50.2/24` | `172.20.50.3/24` | `172.20.50.1/24` |

---

## 2. Quy trình Sao lưu (Backup) Cấu hình Firewall

Thực hiện trên `Firewall-A` mỗi khi cập nhật rule và trước khi chạy kịch bản kiểm thử failover:

```bash
# Bước 1: Kiểm tra cú pháp file cấu hình hiện tại
sudo nft -c -f /etc/nftables.conf

# Bước 2: Xuất (export) toàn bộ ruleset đang chạy ra bản backup có gắn timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
sudo mkdir -p /var/backups/firewall
sudo nft list ruleset > /var/backups/firewall/nftables-${TIMESTAMP}.conf
sudo cp /etc/nftables.conf /var/backups/firewall/etc-nftables-${TIMESTAMP}.conf

# Bước 3: Lưu trạng thái sysctl & bảng định tuyến
sysctl net.ipv4.ip_forward > /var/backups/firewall/sysctl-${TIMESTAMP}.txt
ip addr show > /var/backups/firewall/ip-addr-${TIMESTAMP}.txt
ip route show > /var/backups/firewall/ip-route-${TIMESTAMP}.txt

# Bước 4: Tạo mã băm SHA256 để đối chiếu tính toàn vẹn
sha256sum /var/backups/firewall/*-${TIMESTAMP}.* | tee /var/backups/firewall/sha256-${TIMESTAMP}.sum
```

**Đồng bộ vào Git Repository (Đảm bảo không chứa secret):**
1. Copy file chuẩn `/etc/nftables.conf` về `configs/firewall/nftables-firewall.conf`.
2. Kiểm tra `git diff configs/firewall/nftables-firewall.conf` để chắc chắn không có khóa bí mật hoặc token.

---

## 3. Quy trình Khôi phục (Restore) Cấu hình lên Firewall

Áp dụng khi rule trên `Firewall-A` bị lỗi hoặc khi đồng bộ cấu hình sang `Firewall-B`:

```bash
# Bước 1: Copy cấu hình chuẩn từ repo hoặc bản backup vào /etc/nftables.conf
sudo cp configs/firewall/nftables-firewall.conf /etc/nftables.conf
sudo chmod 0640 /etc/nftables.conf

# Bước 2: Kiểm tra cú pháp (Dry-run) TRƯỚC khi nạp thật
sudo nft -c -f /etc/nftables.conf

# Bước 3: Bật IPv4 forwarding và chống giả mạo đường dẫn ngược (rp_filter)
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.conf.all.rp_filter=1

# Bước 4: Nạp ruleset nguyên tử (atomic load) và bật dịch vụ khởi động cùng OS
sudo nft -f /etc/nftables.conf
sudo systemctl enable --now nftables

# Bước 5: Xác nhận các chain đều ở trạng thái policy drop và counter hoạt động
sudo nft list ruleset
```

---

## 4. Quy trình Chuyển đổi Dự phòng (Failover: `Firewall-A` -> `Firewall-B`)

### Bước 1 — Ghi nhận thời điểm bắt đầu sự cố (`T0`)
```bash
date -Is
# Ví dụ: 2026-11-07T21:45:00+07:00 — Bắt đầu mô phỏng sự cố Firewall-A
```

### Bước 2 — Cô lập `Firewall-A` (Tránh Split-Brain / Xung đột IP Gateway `.1`)
- Nếu đang mô phỏng lỗi phần cứng/OS: thực hiện **Suspend / Power Off** `Firewall-A` trên VMware Workstation hoặc ngắt kết nối (Disconnect) các card mạng của `Firewall-A`.
- Nếu vẫn vào được console của `Firewall-A`:
```bash
# Gỡ các địa chỉ Gateway (.1) khỏi Firewall-A để nhường cho Firewall-B
sudo ip addr del 172.20.10.1/24 dev eth0 || true
sudo ip addr del 172.20.20.1/24 dev eth1 || true
sudo ip addr del 172.20.30.1/24 dev eth2 || true
sudo ip addr del 172.20.40.1/24 dev eth3 || true
sudo ip addr del 172.20.50.1/24 dev eth4 || true
```

### Bước 3 — Kích hoạt `Firewall-B` tiếp nhận vai trò Gateway & Policy
Trên `Firewall-B`:
```bash
# 1. Đảm bảo IP forwarding và nftables đã nạp đúng bản chuẩn
sudo sysctl -w net.ipv4.ip_forward=1
sudo nft -c -f /etc/nftables.conf && sudo nft -f /etc/nftables.conf

# 2. Gán các địa chỉ Gateway (.1) lên các interface tương ứng của Firewall-B
sudo ip addr add 172.20.10.1/24 dev eth0 || true
sudo ip addr add 172.20.20.1/24 dev eth1 || true
sudo ip addr add 172.20.30.1/24 dev eth2 || true
sudo ip addr add 172.20.40.1/24 dev eth3 || true
sudo ip addr add 172.20.50.1/24 dev eth4 || true

# 3. Phát gói Gratuitous ARP để các VM trong từng zone cập nhật MAC mới của Gateway (.1)
for iface_ip in "eth0 172.20.10.1" "eth1 172.20.20.1" "eth3 172.20.40.1" "eth4 172.20.50.1"; do
  set -- $iface_ip
  sudo arping -c 3 -U -I "$1" "$2" || true
done
```

### Bước 4 — Kiểm tra sau chuyển đổi (Post-Failover Verification) & Ghi nhận `T1`
1. **Kiểm tra luồng hợp lệ (Positive Test):**
   - Từ `Test-Client (172.20.10.10)`: `curl -kI https://172.20.20.100` -> Trả về `HTTP/1.1 200 OK`.
   - Kiểm tra kết nối từ `Web-A/B` tới `DB-Primary (172.20.40.11:5432)` -> Hoạt động bình thường.
2. **Kiểm tra luồng bị chặn (Negative Test — Không bị hở rule khi đổi sang Firewall-B):**
   - Từ `Test-Client (172.20.10.10)`: thử kết nối thẳng `nc -zv -w 3 172.20.40.11 5432` và `nc -zv -w 3 172.20.20.21 80` -> Phải **Timeout / Connection refused**.
3. **Kiểm tra Log trên `Firewall-B`:**
   ```bash
   sudo journalctl -k --grep="FW-ALLOW|FW-DENY" -n 25 --no-pager
   ```
4. **Ghi nhận thời điểm hoàn tất (`T1`) và tính Downtime (`T1 - T0`):**
   ```bash
   date -Is
   ```

---

## 5. Quy trình Khôi phục về `Firewall-A` (Failback)

1. Khởi động lại `Firewall-A` ở chế độ cô lập hoặc chỉ giữ IP quản trị `.2` (chưa gán IP `.1`).
2. Kiểm tra file `/etc/nftables.conf` trên `Firewall-A` khớp mã SHA256 với `configs/firewall/nftables-firewall.conf`.
3. Gỡ IP Gateway (`.1`) trên `Firewall-B`, gán lại IP Gateway (`.1`) trên `Firewall-A` và chạy lệnh `arping -U` như Bước 3.
4. Xác nhận lưu lượng và log quay về `Firewall-A`, sau đó tắt `Firewall-B` nếu cần giải phóng RAM cho các bài kiểm thử khác.

---

## 6. Checklist Bằng chứng (Evidence) Cần Thu Thập

Lưu vào `evidence/minh-hung/YYYYMMDD-minh-hung-firewall-failover.md` gồm:
- [ ] Timestamp `T0` (khi tắt `Firewall-A`) và `T1` (khi `Firewall-B` phục vụ thành công).
- [ ] Output `ip -br addr` và `sudo nft list ruleset` trên `Firewall-B`.
- [ ] Kết quả truy cập `https://172.20.20.100` thành công và truy cập `172.20.40.11:5432` từ WAN bị chặn.
- [ ] Trích xuất dòng log `[FW-ALLOW-WAN-VIP]` và `[FW-DENY-WAN-DB]` có timestamp tương ứng trên `Firewall-B`.

---

## 7. Chuyển đổi Dự phòng Tự động bằng Keepalived (VRRP Unicast)

> **Phân vai:** `keepalived` sở hữu và di chuyển các VIP `.1`; `nftables` sở hữu toàn bộ việc lọc gói. File `/etc/nftables.conf` giữ nguyên, giống hệt trên cả hai node. Thiết kế: `docs/superpowers/specs/2026-11-13-firewall-vrrp-unicast-design.md`.

### 7.1 Cài đặt gói (cả hai node)

```bash
sudo apt-get update && sudo apt-get install -y keepalived
```

### 7.2 Sao lưu & đặt cấu hình

```bash
# Sao lưu trước khi thay đổi (cả hai node)
TS=$(date +%Y%m%dT%H%M%S)
sudo cp -a /etc/nftables.conf /etc/nftables.conf.bak.$TS
ip -br addr > /tmp/addr.$TS.txt; ip route > /tmp/route.$TS.txt
[ -f /etc/keepalived/keepalived.conf ] && sudo cp -a /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak.$TS

# CHỈ chạy trên Firewall-A:
sudo install -m 0644 -o root -g root configs/firewall/keepalived-fw-a.conf /etc/keepalived/keepalived.conf
# CHỈ chạy trên Firewall-B:
sudo install -m 0644 -o root -g root configs/firewall/keepalived-fw-b.conf /etc/keepalived/keepalived.conf
# Cả hai node: nạp nftables mới (đã có rule accept VRRP protocol 112 từ peer, nếu không policy drop chặn advert và hai node cùng thành MASTER)
sudo install -m 0644 -o root -g root configs/firewall/nftables-firewall.conf /etc/nftables.conf
# Cả hai node (script phải thuộc root, không ai khác ghi được):
sudo install -m 0755 -o root -g root configs/firewall/keepalived-healthcheck.sh /usr/local/sbin/keepalived-healthcheck.sh
```

### 7.3 Kiểm tra cấu hình (TRƯỚC khi khởi động dịch vụ)

```bash
sudo keepalived -t -f /etc/keepalived/keepalived.conf
sudo nft -c -f /etc/nftables.conf
sudo /usr/local/sbin/keepalived-healthcheck.sh && echo "health OK"
```

### 7.4 Thứ tự khởi động

Baseline: `Firewall-A` đang giữ 5 IP `.1` gán thủ công, `Firewall-B` không giữ IP `.1` nào. Trên `Firewall-A`, gỡ 5 IP `.1` thủ công (như Bước 2 mục 4) để Keepalived tự gán. Các lệnh dưới đây chạy THEO TỪNG NODE, đúng thứ tự:

```bash
# Bước 1 — chạy trên Firewall-B (BACKUP) trước; nạp nftables rồi bật keepalived
sudo systemctl reload nftables || sudo systemctl restart nftables
sudo systemctl enable --now keepalived

# Bước 2 — chạy trên Firewall-A (MASTER) sau; nạp nftables rồi bật keepalived
sudo systemctl reload nftables || sudo systemctl restart nftables
sudo systemctl enable --now keepalived

# Bước 3 — xác nhận sau ~5 giây
# Trên Firewall-A: PHẢI in đúng 5 dòng (172.20.10.1, .20.1, .30.1, .40.1, .50.1)
ip -br addr | grep -cE '172\.20\.(10|20|30|40|50)\.1/'    # Firewall-A: kỳ vọng 5
# Trên Firewall-B: PHẢI là 0 (grep -c vẫn in 0 nhưng thoát mã 1, bình thường)
ip -br addr | grep -cE '172\.20\.(10|20|30|40|50)\.1/'    # Firewall-B: kỳ vọng 0
```

Nếu cả hai node đều giữ 5 VIP (split-brain), VRRP advert đang bị chặn: kiểm tra `sudo nft list chain inet filter input | grep vrrp` và `sudo tcpdump -ni <iface> proto 112`.

### 7.5 Failover tự động

Dừng Keepalived trên `Firewall-A` (`sudo systemctl stop keepalived`) hoặc làm health-check thất bại (nftables dừng / `ip_forward=0`: Keepalived 2.2.7 dùng track script không `weight` trong sync group, sau `fall 2` cả nhóm `VG_FW` chuyển FAULT và nhả đủ 5 VIP, không có phép trừ priority). `Firewall-B` tự nhận cả 5 VIP, không cần `ip addr add` thủ công. Ghi `T0`/`T1`, kiểm tra truy cập DB/SSH vẫn bị chặn và log deny vẫn xuất hiện trên firewall đang hoạt động.

### 7.6 Failback

Khởi động lại Keepalived trên `Firewall-A` (`sudo systemctl start keepalived`; sửa health-check nếu cần). Sau khi health-check pass `rise 2` lần, nhóm thoát FAULT; priority 150 > 100 nên `Firewall-A` (preempt mặc định) lấy lại cả 5 VIP; xác nhận bằng `ip -br addr` trên cả hai node.

### 7.7 Rollback về quy trình thủ công

```bash
# Cả hai node
sudo systemctl disable --now keepalived
sudo rm -f /etc/keepalived/keepalived.conf /usr/local/sbin/keepalived-healthcheck.sh
# Sau đó dùng lại quy trình thủ công ở mục 4 và 5 (gán .1 + arping -U)
```

<!-- ponytail: manual switchover (sections 4-5) kept as rollback path; automatic failover via Keepalived VRRP unicast (section 7); add conntrackd when connection-state sync is required -->
