# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-fw-a-antispoof

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-fw-a-antispoof` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:05:47+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:05:47+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.2 'sudo nft list chain inet filter prerouting'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | FW-00: Anti-spoofing raw prerouting rules present for all 5 interfaces |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.50.2' (ED25519) to the list of known hosts.
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
}
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
