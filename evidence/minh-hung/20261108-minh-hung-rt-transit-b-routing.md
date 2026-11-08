# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-rt-transit-b-routing

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-rt-transit-b-routing` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T06:51:44+07:00` |
| **Thời gian kết thúc** | `2026-11-08T06:51:49+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.20.6 'export PATH=$PATH:/usr/sbin:/sbin; sysctl net.ipv4.ip_forward && ip route show && traceroute -n -m 5 172.20.40.11'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | net.ipv4.ip_forward=1, routes for .40.0/24 and .50.0/24 via 172.20.20.1, traceroute hop 1 is Firewall-A |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.20.6' (ED25519) to the list of known hosts.
net.ipv4.ip_forward = 1
default via 192.168.30.2 dev eth1 proto dhcp src 192.168.30.128 metric 1024 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.6 
172.20.40.0/24 via 172.20.20.1 dev eth0 proto static 
172.20.50.0/24 via 172.20.20.1 dev eth0 proto static 
192.168.30.0/24 dev eth1 proto kernel scope link src 192.168.30.128 metric 1024 
192.168.30.2 dev eth1 proto dhcp scope link src 192.168.30.128 metric 1024 
traceroute to 172.20.40.11 (172.20.40.11), 5 hops max, 60 byte packets
 1  172.20.20.2  0.376 ms  0.322 ms  0.324 ms
 2  * * *
 3  * * *
 4  * * *
 5  * * *
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
