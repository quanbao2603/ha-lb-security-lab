# Evidence — LB-A: HTTPS, stats nội bộ, Keepalived VIP

- Ngày: 2026-11-08 (Asia/Ho_Chi_Minh, +07)
- Người thực hiện: Quan Bảo
- Máy chạy: LB-A (192.168.179.170 / lab 172.20.21.10), backend Web-A/Web-B bật
- Phạm vi: Site A — load balancer

## 1. HTTPS + health check /healthz + round-robin

Lệnh (trên LB-A, sau khi tạo cert lab và bind HTTPS):

```bash
for i in 1 2 3 4; do curl -sk https://172.20.21.10; done
```

Expected: luân phiên Web-A/Web-B. Actual:

```text
<h1>Web-A</h1>
<p>Backend server: 172.20.21.20</p>
<h1>Web-B</h1>
<p>Backend server: 172.20.21.30</p>
<h1>Web-A</h1>
<p>Backend server: 172.20.21.20</p>
<h1>Web-B</h1>
<p>Backend server: 172.20.21.30</p>
```

→ PASS. Backend UP nhờ `/healthz` trả 200 (health check `GET /healthz`).

## 2. Stats nội bộ có bảo vệ mật khẩu

Lệnh:

```bash
curl -s -o /dev/null -w '%{http_code}\n' -u 'admin:<mat-khu>' http://172.20.21.10:8404/stats
curl -s -o /dev/null -w '%{http_code}\n' http://172.20.21.10:8404/stats
```

| Trường hợp | Expected | Actual | Kết quả |
|---|---|---|---|
| Có mật khẩu đúng | 200 | 200 | PASS |
| Không mật khẩu | 401 | 401 | PASS |

Ghi chú lỗi đã sửa: mật khẩu chứa `#` bị HAProxy cắt thành comment gây 401 cả hai
chiều; đổi mật khẩu bỏ `#` thì đúng 200/401. Mật khẩu thật không commit vào repo.

## 3. Keepalived VIP

Lệnh:

```bash
systemctl is-active keepalived
ip -br addr show ens37
for i in 1 2 3 4; do curl -sk https://172.20.21.100; done
```

Actual:

```text
active
ens37 UP 172.20.21.10/24 172.20.21.100/24 fe80::20c:29ff:fe5b:f7ec/64
<h1>Web-A</h1> ... <h1>Web-B</h1> ... (luân phiên)
```

→ PASS. VIP `172.20.21.100` do Keepalived giữ trên ens37; HAProxy frontend bind VIP,
client truy cập dịch vụ qua VIP.

## Giới hạn

Một node LB-A (không có LB-B): chưa demo failover chính LB. Failover backend web
xem evidence kiểm thử ở mốc kiểm thử.