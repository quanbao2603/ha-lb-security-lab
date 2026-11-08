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

<!-- ponytail: manual IP switchover + gratuitous ARP to fit sequential 6-7 VM RAM budget; upgrade to Keepalived VRRP + conntrackd when both Firewall-A and Firewall-B run 24/7 -->
