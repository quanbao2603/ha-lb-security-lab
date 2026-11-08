# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-fw-a-mgmt-ssh-allow

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-fw-a-mgmt-ssh-allow` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T07:05:42+07:00` |
| **Thời gian kết thúc** | `2026-11-08T07:05:43+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.10 'nc -zv -w 2 172.20.40.11 22' && ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.2 'sudo journalctl -k --grep="FW-ALLOW-MGMT-SSH" -n 2 --no-pager'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | FW-08: MGMT -> DB-Primary port 22 succeeds and kernel log records FW-ALLOW-MGMT-SSH |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `0` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **PASS** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.50.10' (ED25519) to the list of known hosts.
Connection to 172.20.40.11 22 port [tcp/ssh] succeeded!
Warning: Permanently added '172.20.50.2' (ED25519) to the list of known hosts.
Nov 08 07:05:44 fw-a kernel: [FW-ALLOW-MGMT-SSH:] IN=eth4 OUT= MAC=00:0c:29:96:55:68:00:50:56:c0:00:0f:08:00 SRC=172.20.50.254 DST=172.20.50.2 LEN=52 TOS=0x00 PREC=0x00 TTL=128 ID=51599 DF PROTO=TCP SPT=59360 DPT=22 WINDOW=65535 RES=0x00 SYN URGP=0 
Nov 08 07:05:44 fw-a kernel: [FW-ALLOW-MGMT-SSH:] IN=eth4 OUT=eth3 MAC=00:0c:29:96:55:68:00:0c:29:80:0f:41:08:00 SRC=172.20.50.10 DST=172.20.40.11 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=17097 DF PROTO=TCP SPT=59648 DPT=22 WINDOW=64240 RES=0x00 SYN URGP=0 
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
