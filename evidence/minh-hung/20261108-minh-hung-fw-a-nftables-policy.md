# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-fw-a-nftables-policy

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-fw-a-nftables-policy` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T06:52:02+07:00` |
| **Thời gian kết thúc** | `2026-11-08T06:52:06+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.2 'export PATH=$PATH:/usr/sbin:/sbin; ROLE=firewall /opt/lab/scripts/verify-routes-and-firewall.sh && sudo nft list ruleset | head -n 35'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | verify-routes-and-firewall.sh passes with 0 errors and nftables active |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.50.2' (ED25519) to the list of known hosts.
======================================================================
 KIỂM TRA ROUTING & FIREWALL — MINH HÙNG (2026-11-08T06:52:04+07:00)
 Host: fw-a | Role: firewall
======================================================================

=== [1/4] Kiểm tra bảng định tuyến (Routing Table & Tailscale) ===
172.20.10.0/24 dev eth0 proto kernel scope link src 172.20.10.2 
172.20.20.0/24 dev eth1 proto kernel scope link src 172.20.20.2 
172.20.20.5 via 172.20.20.6 dev eth1 proto static 
172.20.20.10 via 172.20.20.6 dev eth1 proto static 
172.20.20.11 via 172.20.20.6 dev eth1 proto static 
172.20.20.21 via 172.20.20.6 dev eth1 proto static 
172.20.20.22 via 172.20.20.6 dev eth1 proto static 
172.20.20.100 via 172.20.20.6 dev eth1 proto static 
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
table inet filter {
	chain prerouting {
		type filter hook prerouting priority raw; policy accept;
		iifname != "lo" ip saddr 127.0.0.0/8 limit rate 10/minute log prefix "[FW-DENY-SPOOF] " counter packets 0 bytes 0 drop
		iifname "eth0" ip saddr != 172.20.10.0/24 limit rate 10/minute log prefix "[FW-DENY-SPOOF] " counter packets 0 bytes 0 drop
		iifname "eth1" ip saddr != 172.20.20.0/24 limit rate 10/minute log prefix "[FW-DENY-SPOOF] " counter packets 0 bytes 0 drop
		iifname "eth2" ip saddr != 172.20.30.0/24 limit rate 10/minute log prefix "[FW-DENY-SPOOF] " counter packets 0 bytes 0 drop
		iifname "eth3" ip saddr != 172.20.40.0/24 limit rate 10/minute log prefix "[FW-DENY-SPOOF] " counter packets 0 bytes 0 drop
		iifname "eth4" ip saddr != 172.20.50.0/24 limit rate 10/minute log prefix "[FW-DENY-SPOOF] " counter packets 0 bytes 0 drop
	}

	chain input {
		type filter hook input priority filter; policy drop;
		iifname "lo" accept
		ct state established,related accept
		ct state invalid limit rate 10/minute log prefix "[FW-DENY-INVALID] " counter packets 0 bytes 0 drop
		ip saddr 172.20.10.0/24 tcp dport 22 log prefix "[FW-DENY-WAN-SSH] " counter packets 0 bytes 0 drop
		ip saddr 172.20.50.0/24 tcp dport 22 ct state new log prefix "[FW-ALLOW-MGMT-SSH:] " counter packets 9 bytes 468 accept
		ip saddr { 172.20.20.0/24, 172.20.40.0/24, 172.20.50.0/24 } ip protocol icmp icmp type echo-request limit rate 5/second log prefix "[FW-ALLOW-ICMP-IN] " counter packets 1 bytes 84 accept
		limit rate 20/minute burst 40 packets log prefix "[FW-DENY-INPUT-DEFAULT] " flags all counter packets 512 bytes 34100 drop
		counter packets 308 bytes 19657 drop
	}

	chain forward {
		type filter hook forward priority filter; policy drop;
		ct state established,related accept
		ct state invalid limit rate 10/minute log prefix "[FW-DENY-INVALID] " counter packets 0 bytes 0 drop
		ip saddr 172.20.10.0/24 ip daddr { 172.20.20.21, 172.20.20.22 } log prefix "[FW-DENY-WAN-DIRECT:WEB] " counter packets 0 bytes 0 drop
		ip saddr 172.20.10.0/24 ip daddr 172.20.40.0/24 log prefix "[FW-DENY-WAN-DIRECT:DB] " counter packets 0 bytes 0 drop
		ip saddr 172.20.10.0/24 ip daddr 172.20.50.0/24 log prefix "[FW-DENY-WAN-DIRECT:MGMT] " counter packets 0 bytes 0 drop
		ip saddr 172.20.10.0/24 ip daddr 172.20.30.0/24 log prefix "[FW-DENY-WAN-DIRECT:APP] " counter packets 0 bytes 0 drop
		ip saddr 172.20.10.0/24 ip daddr 172.20.20.100 tcp dport { 80, 443 } ct state new log prefix "[FW-ALLOW-WAN-VIP:] " counter packets 0 bytes 0 accept
		ip saddr { 172.20.20.10, 172.20.20.11 } ip daddr { 172.20.20.21, 172.20.20.22 } tcp dport 80 ct state new log prefix "[FW-ALLOW-LB-WEB:] " counter packets 0 bytes 0 accept
		ip saddr { 172.20.20.21, 172.20.20.22 } ip daddr { 172.20.40.11, 172.20.40.12 } tcp dport 5432 ct state new log prefix "[FW-ALLOW-WEB-DB:] " counter packets 0 bytes 0 accept
		ip saddr 172.20.40.11 ip daddr 172.20.40.12 tcp dport 5432 ct state new log prefix "[FW-ALLOW-DB-REPL:] " counter packets 0 bytes 0 accept
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
