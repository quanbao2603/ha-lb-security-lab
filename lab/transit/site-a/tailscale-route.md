# Tailscale subnet route — Transit-A (Site A)

## Quảng bá route

Trên Transit-A (IPv4 forwarding đã bật):

```bash
sudo tailscale up --advertise-routes=172.20.21.0/24
```

Output thực tế (2026-11-08):

```text
Warning: IPv6 forwarding is disabled.
Warning: UDP GRO forwarding is suboptimally configured on ens33 ...
Some peers are advertising routes but --accept-routes is false
```

Các cảnh báo này không ngăn route IPv4 hoạt động (IPv4 forwarding đã bật; lab chỉ dùng
IPv4). `--accept-routes false` chỉ ảnh hưởng chiều nhận route từ peer, không chặn máy
khác truy cập lab qua Transit-A.

## Phê duyệt route (Admin Console)

Machines → `transit-a` → `…` → **Edit route settings** → bật `172.20.21.0/24` → **Save**.
Đã phê duyệt ngày 2026-11-08 (ảnh chụp màn hình route settings đã bật).

## Kiểm chứng end-to-end

Transit-A phải bật. Từ Windows CMD:

```cmd
ping 172.20.21.10
```

Actual:

```text
Reply from 172.20.21.10: bytes=32 time=... TTL=63
Packets: Sent = 3, Received = 3, Lost = 0 (0% loss)
```

TTL=63 xác nhận gói đi qua Transit-A (routing), không phải cùng L2.

```cmd
curl http://172.20.21.10
```

Actual: trả luân phiên `<h1>Web-A</h1>` / `<h1>Web-B</h1>` (khi Web-A/Web-B bật).
Trước đó trả `503` khi backend chưa bật — xác nhận đường tới HAProxy thông nhưng
backend chưa sẵn sàng.

## Ownership

- ACL và route policy toàn tailnet: Minh Hùng (`configs/tailscale/`).
- Transit-A chỉ advertise subnet Site A `172.20.21.0/24`; không sửa ACL của Hùng.
- Không commit token Tailscale hay file state.