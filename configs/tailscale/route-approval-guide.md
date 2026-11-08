# Hướng Dẫn Advertise & Approve Subnet Route An Toàn (Tailscale)

## 1. Nguyên tắc an toàn cốt lõi

1. **Chỉ cài Tailscale trên 2 Linux Transit VM:** `Transit-A (172.20.20.5)` và `Transit-B (172.20.20.6)`. Không cài Tailscale lên `Web-A/B`, `DB-Primary`, `DB-Replica` để mọi gói tin ứng dụng luôn phải đi qua `Firewall-A`.
2. **Không dùng Exit Node:** Không bao giờ truyền cờ `--advertise-exit-node` trên các máy lab.
3. **Không lưu Secret trong Repo:** Không ghi Auth Key thật, API Token hay file `tailscaled.state` vào cấu hình hoặc log kiểm thử.
4. **Áp dụng ACL trước, Approve Route sau:** Luôn cập nhật `tailscale-acl.hujson` trên Admin Console trước khi bật bất kỳ subnet route nào.

---

## 2. Phạm vi Subnet được phép Advertise & Phê duyệt

| Thiết bị | Tag bắt buộc | Subnet được phép Advertise | Subnet CẤM Advertise | Kiểm soát bắt buộc |
|---|---|---|---|---|
| **Transit-B** (`172.20.20.6`) | `tag:transit-b` | `172.20.20.0/24`, `172.20.40.0/24`, `172.20.50.0/24` | `172.20.10.0/24` (WAN-LAB), `0.0.0.0/0`, LAN vật lý | Phê duyệt thủ công `.40.0/24` & `.50.0/24`; route nội bộ phải đi qua `172.20.20.1` (`Firewall-A`) |
| **Transit-A** (`172.20.20.5`) | `tag:transit-a` | `172.20.20.0/24` (và `172.20.30.0/24` nếu dùng vùng APP tại Site A) | `172.20.10.0/24` (WAN-LAB), `0.0.0.0/0`, LAN vật lý | Chỉ nhận route qua `--accept-routes` và chịu giới hạn bởi `tailscale-acl.hujson` |

---

## 3. Các bước Advertise an toàn trên Transit-B

### Bước 1: Xác minh Transit-B không nối thẳng vào mạng DB/MGMT
Trước khi quảng bá route, kiểm tra bảng định tuyến trên `Transit-B` để chắc chắn gói tin đi tới `DATABASE` và `MGMT` bắt buộc phải đi qua `Firewall-A (172.20.20.1)`:

```bash
ip route show 172.20.40.0/24
# Kết quả đúng: 172.20.40.0/24 via 172.20.20.1 dev eth0
ip route show 172.20.50.0/24
# Kết quả đúng: 172.20.50.0/24 via 172.20.20.1 dev eth0
```

### Bước 2: Quảng bá Subnet Route kèm Tag định danh
Đăng nhập tương tác (khuyến nghị cho lab) hoặc truyền Auth Key tạm thời một lần qua biến môi trường (không lưu lại trong shell history):

```bash
sudo tailscale up \
  --advertise-routes=172.20.20.0/24,172.20.40.0/24,172.20.50.0/24 \
  --accept-routes \
  --advertise-tags=tag:transit-b
```
> **Lưu ý:** Nếu dùng reusable/ephemeral auth key, đặt khoảng trắng đầu dòng lệnh (với `HISTCONTROL=ignorespace`) và dùng biến giả lập lúc viết tài liệu: `TS_AUTHKEY="TAILSCALE_AUTHKEY_PLACEHOLDER"`.

---

## 4. Quy trình Approve Route trên Tailscale Admin Console

1. **Bước 1 — Nạp và kiểm thử ACL:**
   - Mở tab **Access Controls** trong Tailscale Admin Console.
   - Dán cấu hình từ `configs/tailscale/tailscale-acl.hujson` và kiểm tra khối `"tests"` vượt qua 100% trước khi bấm **Save**.
2. **Bước 2 — Đối chiếu định danh máy (`Machines`):**
   - Chọn máy `transit-b`, xác nhận IP Tailscale, OS Linux và đã mang đúng nhãn **`tag:transit-b`** (vô hiệu hóa key expiry chỉ cho riêng Transit VM nếu cần giữ phiên trong 7 ngày lab).
3. **Bước 3 — Kiểm tra từng dải trước khi bật (`Edit route settings`):**
   - Chỉ bật phê duyệt cho đúng 3 subnet:
     - [x] `172.20.20.0/24` (DMZ)
     - [x] `172.20.40.0/24` (DATABASE — đã được ACL khóa chặt chỉ cho `tag:transit-a` vào `.11/.12` port `5432,3306`)
     - [x] `172.20.50.0/24` (MGMT — chỉ mở syslog `.10:514` và SSH quản trị)
   - **Từ chối ngay** nếu thấy quảng bá nhầm `172.20.10.0/24`, `0.0.0.0/0`, `192.168.0.0/16` hoặc dải mạng thật của host.
4. **Bước 4 — Hậu kiểm bắt buộc sau khi Approve:**
   - Từ một máy cá nhân khác trong tailnet (không thuộc `tag:transit-a`), chạy thử `nc -zv -w 3 172.20.40.11 5432` → **Phải bị từ chối**.
   - Từ `Transit-A`, chạy `traceroute -n 172.20.40.11` → **Phải thấy hop `172.20.20.1` (`Firewall-A`)**.

---

## 5. Thu hồi Route khẩn cấp (Rollback / Revoke)

Khi kết thúc buổi lab hoặc phát hiện sự cố cấu hình sai:

- **Cách 1 (tại máy Transit-B):**
  ```bash
  sudo tailscale set --advertise-routes=""
  ```
- **Cách 2 (trên Tailscale Admin Console):**
  Vào **Machines** → `transit-b` → **Edit route settings** → Bỏ chọn toàn bộ các subnet route và bấm **Save**.
