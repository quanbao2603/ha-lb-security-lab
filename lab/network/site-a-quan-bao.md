# Đề xuất mạng Site A — Quan Bảo (chờ Minh Hùng review)

File đề xuất riêng của Bảo cho phần Site A. Sơ đồ tổng + đường route/firewall sẽ
merge vào `lab/network/` sau khi Hùng review và hai người thống nhất (file chung).

## Sơ đồ Site A

```
[Windows admin]
      | Tailscale (tailnet)
      v
[Transit-A]  ens33 NAT 192.168.179.169
   100.99.198.105 (tailscale0)
   ens37 lab 172.20.21.5 ----+-----------------------------+
                             |        VMnet2 172.20.21.0/24 |
                             |                             |
                        [LB-A] .10                    [Test-Client] .40
                  HAProxy + Keepalived
                  VIP 172.20.21.100
                             |
                +------------+------------+
                |                         |
           [Web-A] .20               [Web-B] .30
           Nginx /healthz            Nginx /healthz
```

## Luồng dịch vụ

1. Client (Test-Client hoặc Windows qua Tailscale) → VIP `172.20.21.100:443`.
2. LB-A kết thúc TLS (cert lab) → round-robin → Web-A/Web-B:80.
3. Health check `GET /healthz` quyết định backend UP/DOWN.
4. Stats nội bộ tại `172.20.21.10:8404` (có mật khẩu), không public WAN.

## Phần chờ Hùng review / bổ sung

- Phân vùng zone (WAN/DMZ/APP/DATABASE/MGMT) + firewall deny-by-default đặt ở đâu
  trong đường đi (Hiện Site A dùng một subnet chung; Hùng thiết kế zone/firewall).
- Đường route liên site Transit-A ↔ Transit-B và ACL Tailscale.
- Vị trí Log-Monitor thu log HAProxy/web/firewall/DB.
- Quy tắc chặn web bypass / SSH WAN / DB trực tiếp (negative test của Bảo phụ thuộc).