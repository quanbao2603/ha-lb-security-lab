# Thông số VM — Site A (Quan Bảo)

Nền tảng: VMware Workstation. Guest: Debian 13 (trixie) amd64 minimal, không GUI,
chỉ SSH server + standard utilities. Username quản trị: `quanbao2603`.

## Bảng VM

| VM | RAM | Disk | vCPU | NIC1 (NAT/VMnet8) | NIC2 (VMnet2 lab) |
|---|---|---|---|---|---|
| Transit-A | 2048 MB | 20 GB | 2 | DHCP 192.168.179.169 | static 172.20.21.5/24 |
| LB-A | 2048 MB | 20 GB | 1–2 | DHCP 192.168.179.170 | static 172.20.21.10/24 + VIP .100 |
| Web-A | 2048 MB | 20 GB | 2 | DHCP 192.168.179.171 | static 172.20.21.20/24 |
| Web-B | 2048 MB | 20 GB | 2 | DHCP 192.168.179.172 | static 172.20.21.30/24 |
| Test-Client | 2048 MB | 20 GB | 2 | DHCP 192.168.179.173 | static 172.20.21.40/24 |

Ghi chú:
- vCPU theo profile tiết kiệm RAM (máy host 16 GB); LB-A giảm còn 1 để chạy đồng thời.
  Có thể chỉnh thêm khi cần bật nhiều VM.
- NIC dùng `e1000`. VMnet2 là host-only lab, **DHCP tắt**, subnet `172.20.21.0/24`.
- NAT (VMnet8) chỉ phục vụ SSH quản trị + Internet khi cài gói; không phải đường dịch vụ.
- Transit-A thêm `tailscale0` = `100.99.198.105` (Tailscale subnet router).

## Quy ước clone (quan trọng)

Clone full từ Transit-A baseline khi chưa cài role-specific. Sau mỗi clone:
- Đặt hostname riêng; tạo `/etc/machine-id` mới; tạo lại SSH host keys
  (`rm -f /etc/ssh/ssh_host_*; ssh-keygen -A`).
- **Sửa `vmxstats.filename` trong `.vmx` thành tên riêng** (ví dụ `LB-A.scoreboard`).
  Nếu để chung `Transit-A.scoreboard`, bật VM thứ hai sẽ lỗi
  `scoreboard file establishment failed / Module 'VmxStats' power on failed`.
  Đây là lỗi VMware phía host, KHÔNG phải `machine-id` của Debian.
- Dọn thư mục `.lck` cũ khi VMware đã đóng hoàn toàn và không còn `vmware-vmx.exe`.

## Snapshot mốc

- `baseline-debian13-sudo` (sau baseline + sudo).
- `baseline-tailscale-online` (Transit-A sau khi Tailscale online).
- Tạo snapshot trước mỗi mốc cấu hình lớn để rollback.

## Vận hành tiết kiệm RAM

Chỉ bật VM đang cấu hình; tắt các VM khác. Khi test cần nhiều VM, bật tối thiểu đủ
(ví dụ failover web cần LB-A + Web-A + Web-B). Không bật cả 5 VM cùng lúc nếu không cần.