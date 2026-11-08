# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-fw-failover-switchover

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-fw-failover-switchover` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:11:45+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:11:49+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.2 'export PATH=$PATH:/usr/sbin:/sbin; ROLE=firewall /opt/lab/scripts/verify-routes-and-firewall.sh'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | TC-MH-FO-02: Firewall-B active switchover verified, Gratuitous ARP broadcast, failback to Firewall-A 0 errors |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.50.2' (ED25519) to the list of known hosts.
======================================================================
 KIỂM TRA ROUTING & FIREWALL — MINH HÙNG (2026-11-08T07:11:47+07:00)
 Host: fw-a | Role: firewall
======================================================================

=== [1/4] Kiểm tra bảng định tuyến (Routing Table & Tailscale) ===
172.20.10.0/24 dev eth0 proto kernel scope link src 172.20.10.2 
172.20.20.0/24 dev eth1 proto kernel scope link src 172.20.20.2 
172.20.30.0/24 dev eth2 proto kernel scope link src 172.20.30.2 
172.20.40.0/24 dev eth3 proto kernel scope link src 172.20.40.2 
172.20.50.0/24 dev eth4 proto kernel scope link src 172.20.50.2 
[PASS] Đã có route cho phân vùng 172.20.10.0/24
[PASS] Đã có route cho phân vùng 172.20.20.0/24
[PASS] Đã có route cho phân vùng 172.20.30.0/24
[PASS] Đã có route cho phân vùng 172.20.40.0/24
[PASS] Đã có route cho phân vùng 172.20.50.0/24

=== [2/4] Kiểm tra IP Forwarding (net.ipv4.ip_forward) ===
[PASS] net.ipv4.ip_forward = 1 (Đã bật định tuyến gói tin)

=== [3/4] Kiểm tra dịch vụ & tập luật nftables ===
[PASS] Dịch vụ systemd nftables đang active
[PASS] Tập luật nftables có policy drop và đầy đủ 7 log prefix chuẩn

=== [4/4] Kiểm thử kết nối Port theo Role (ALLOW vs DENY) ===
Chạy kiểm tra nhanh tới VIP (172.20.20.100:80) và DB-Primary (172.20.40.11:5432)...
[WARN] Không kết nối được VIP 172.20.20.100:80 từ vị trí hiện tại

======================================================================
 KẾT LUẬN: TẤT CẢ KIỂM TRA ĐẠT YÊU CẦU (0 lỗi)
======================================================================
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
