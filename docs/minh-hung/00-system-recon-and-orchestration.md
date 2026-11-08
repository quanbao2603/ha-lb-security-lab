# Báo Cáo Thăm Dò Hệ Thống & Điều Phối Môi Trường Dự Án (Minh Hùng)

## 1. Kết quả thăm dò hệ thống máy Host (`desktop-ni199v3`)

| Hạng mục | Thông số thực tế phát hiện | Đánh giá độ sẵn sàng |
|---|---|---|
| Hệ điều hành | Windows 11 x64 (Build 26200) | Đạt chuẩn |
| CPU | 12th Gen Intel Core i5-12500H (16 luồng logic) | Dư tải cho 6 VM (tổng 8 vCPU) |
| RAM | **31.71 GB** (còn trống ~13.00 GB khi chạy nền) | Đủ chạy toàn bộ 6 VM của Minh Hùng (~6.75 GB) hoặc profile tuần tự (~4.25 GB) |
| Ổ đĩa `D:\` | Còn trống **299.08 GB** / 931.5 GB | Rất rộng cho toàn bộ VM, snapshot `day-1-clean` và ISO |
| VMware Workstation | **Pro 25.0.0 build-24995812** (`VMnetDHCP`, `VMware NAT Service` đang chạy; `VMnet1` `192.168.42.1/24`, `VMnet8` `192.168.30.1/24` Up) | Sẵn sàng tạo các Host-Only VMnet cô lập |
| Tailscale | Phiên bản **1.104.5** đang chạy (`100.76.150.63`) | Chỉ dùng quản trị host; Tailscale lab sẽ cài trên `Transit-B` (`172.20.20.6`) |
| WSL2 | Đã cài (`archlinux`, `kali-linux`, `Ubuntu-26.04` đang Stopped) | Đã tạo `.wslconfig` giới hạn `memory=2GB`, `processors=2` để nhường RAM cho VMware |
| Git & Kho code | `git 2.44.0.windows.1`; đã clone vào `D:\Lab\ha-lb-security-lab` (nhánh `main`) | Đã cài `.git/hooks/pre-commit` chặn lộ secret và chặn sửa nhầm thư mục của Quan Bảo |
| ISO Linux | Chưa có sẵn ISO Linux trên ổ `D:\` (chỉ có ISO Windows) | Cung cấp sẵn script `scripts/minh-hung/download-debian-iso.ps1` tải Debian 12 netinst (~630 MB) về `D:\Lab\isos\` |

---

## 2. Cấu trúc môi trường thực thi đã dựng trên máy

- `D:\Lab\ha-lb-security-lab\`: Kho Git chính thức trên nhánh `main`.
- `D:\Lab\vms\minh-hung\`: Thư mục chứa máy ảo VMware riêng cho 6 VM:
  - `Transit-B`, `Firewall-A`, `Firewall-B`, `DB-Primary`, `DB-Replica`, `Log-Monitor`.
- `D:\Lab\isos\`: Thư mục lưu ISO cài đặt Linux minimal / OPNsense.
- `D:\Lab\.wslconfig`: Cấu hình khóa trần RAM WSL2 ở mức 2 GB.

---

## 3. Sơ đồ phân công 4 Sub-agent chuyên trách

| Sub-agent | Task ID | Phạm vi Ownership được giao | Đầu ra chính |
|---|---|---|---|
| `infra-agent` | `task-1` | `configs/vmware/minh-hung/`, `lab/transit/site-b/`, `configs/tailscale/` | Bảng VM/RAM profile, script `Transit-B`, Tailscale ACL & hướng dẫn approve route |
| `firewall-agent` | `task-2` | `lab/firewall/`, `configs/firewall/` | Firewall Rule Matrix, cấu hình `nftables` deny-by-default + log, runbook failover Firewall-A/B |
| `db-mon-agent` | `task-3` | `lab/database/`, `lab/monitoring/` | PostgreSQL Primary/Replica replication, SQL least-privilege, runbook promote DB, `rsyslog` tập trung |
| `qa-docs-agent` | `task-4` | `scripts/minh-hung/`, `lab/testing/minh-hung/`, `evidence/minh-hung/`, `docs/minh-hung/` | Bộ script kiểm tra host/route/DB/evidence, ma trận test case, template evidence và runbook 7 ngày |

<!-- ponytail: host-level VMware directory scaffold; upgrade to automated Packer/Ansible provisioning only if rebuilding all 6 VMs repeatedly -->
