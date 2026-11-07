# ha-lb-security-lab

**Lab HA-LB-Sec** — Xây dựng hệ thống cân bằng tải và dự phòng cho dịch vụ ứng dụng,
cơ sở dữ liệu và tường lửa, có tự động hoá triển khai và kiểm chứng bằng số liệu.

Perimeter nhiều vùng có HA thật (2× OPNsense + CARP + pfsync), Suricata inline IPS,
chính sách firewall dạng mã nguồn, dịch vụ được bảo vệ nhiều lớp — **mọi tuyên bố an ninh
đều phải có bằng chứng đo được**, không mô tả bằng lời.

> Trạng thái: khung repo đã dựng, nội dung đang được thiết kế. Các mục `[ ]` dưới đây
> là danh sách cần hoàn thành, không phải mô tả tính năng đã xong.

---

## 1. Kiến trúc

5 vùng mạng, 12 máy ảo, tất cả chạy trên **một host** (máy Hùng). Máy Bảo là
control plane + red plane, làm việc từ xa qua Tailscale.

| Vùng | Dải | Thành phần | IPS |
|---|---|---|---|
| WAN | 10.0.0.0/24 | attacker, sensor, WAN của opns1/2, CARP VIP .100 | inline |
| DMZ-FRONT | 192.168.20.0/24 | lb1, lb2, Keepalived VIP .100 | inline |
| DMZ-APP | 192.168.21.0/24 | web1, web2 (Apache + CRS), session trong DB | inline |
| TRUSTED | 192.168.30.0/24 | pg1, pg2, DB VIP .100 (repmgr + pgBackRest) | — |
| MGMT | 192.168.99.0/24 | obs (bastion + Prometheus/Grafana/Loki + witness), ca | — |

Hai quy tắc bất biến, vi phạm là hệ thống sai mà không báo lỗi:

1. **Mỗi cặp HA phải nằm trên cùng một host.** VIP của Keepalived (VRRP) và DB VIP do
   `promote.sh` gán là cơ chế tầng 2 — gratuitous ARP không đi qua lớp 3.
2. **Không vùng dịch vụ nào được nằm cùng broadcast domain với WAN.** Nếu có, attacker
   `ip route add` rồi ARP thẳng tới VIP và đi vòng qua perimeter. Chi tiết ở
   [docs/decisions.md](docs/decisions.md).

## 2. Yêu cầu

| | Máy Hùng (32 GB) | Máy Bảo (16 GB) |
|---|---|---|
| VMware Workstation Pro (miễn phí cá nhân) | ✔ | — |
| Tailscale, `tailscale set --expiry=0` | ✔ | ✔ |
| OpenSSH Server (sshd, StartupType Automatic) | ✔ | — |
| WSL2 + Ansible-core ≥ 2.14, Python 3, Git | ✔ | ✔ |
| `ansible-lint`, `gitleaks`, `jq`, `shellcheck` | — | ✔ |

## 3. Bắt đầu nhanh

```bash
# 0. Tuong tac voi repo luon tu goc repo (ansible.cfg chi duoc doc o day)
cd ~/Projects/ha-lb-security-lab

# 1. Cai collection trung ban pin trong requirements.yml
make install

# 2. COP NGAY 1 — quyét dinh moi thuc nghi tu xa co dung duoc khong
make preflight        # ProxyJump tung vung + tailscale status = direct
make ping             # ansible ping du 12 VM

# 3. Kiem tra truoc khi mo bat ky PR nao
make check            # policy-lint + syntax + ansible-lint + gitleaks

# 4. Dy / ap dung / do
make converge         # toan bo lab
make apply            # chinh sach firewall (Bao viet YAML, Hung chay lenh nay)
make drift            # thiet bi lech Git? (khong ghi de)

# 5. Gay su co va do ket qua
make chaos S=kill_db
make matrix && make report
```

## 4. Cấu trúc

```
docs/          hop dong, kien truc, decisions (rejected designs), runbook, MITRE
infra/vmware/  vmnet plan + script tao/dieu khien VM tren may Hung
inventory/     lab.ini (12 VM, 6 group) + group_vars per group
ansible/       site.yml, pb/ (8 playbook), roles/ (20), vault/
policy/        zones/aliases/rules/nat/ips + schema + tests  ← nguon chan ly firewall
attacks/       payload theo lop tan cong + expected.json de cham diem T-09
scripts/       verify_access (cong ngay 1), chaos/, evidence/
evidence/      raw/ (CSV commit) · derived/ (sinh tu, gitignore)
certs/         chi ca.crt + *.csr   ·   secrets/ hoan toan ngoai Git
report/        bao cao, slide (video qua Git LFS hoac Drive)
```

## 5. Quy trình làm việc chung

- Nhánh `h/<topic>` (Hùng) và `b/<topic>` (Bảo); `main` chỉ nhận PR khi `make check` xanh.
- **Chính sách firewall:** Bảo viết `policy/*.yml`, Hùng chạy `make apply`. Không ai sửa
  rule trên GUI — `make drift` sẽ bắt được.
- Mỗi rule mang `POLICY-ID` (POL-001…) và trỏ tới một kịch bản test (`test: T-07`).
  Rule không có ID không được merge.
- Tag theo mốc: `d02-green`, `d05-green`, `d08-checkpoint1`, `d10-checkpoint2`, `final`.
- Snapshot VM: `clean` (ngày 1) · `green` (cuối ngày) · `before-<T-xx>` (trước test phá) ·
  `IPS-off` (trước khi bật inline).

## 6. Ma trận kiểm thử

| Mã | Kịch bản | Ngưỡng PASS | Trạng thái |
|---|---|---|---|
| T-01 | Phân phối tải | 30 req/s, cả 2 web ≥ 40% | [ ] |
| T-02 | Chết 1 web node | phát hiện ≤ 6 s, 0 lỗi 5xx | [ ] |
| T-03 | Keepalived VIP đổi chủ | ≤ 10 s, mất ≤ 0.5% request | [ ] |
| T-04 | CARP giữ session (pfsync) | đổi master ≤ 5 s, iperf3/ssh không đứt | [ ] |
| T-05 | Cắt đường pfsync | không có 2 MASTER | [ ] |
| T-06 | cfgsync drift | master không bị ghi đè im lặng | [ ] |
| T-07 | Ma trận chính sách 24 combo | khớp 100%, counter > 0 | [ ] |
| T-08 | Apply policy dưới tải | 0 gián đoạn, state không giảm | [ ] |
| T-09 | IPS + WAF chặn payload | ≥ 90% chặn, có alert | [ ] |
| T-10 | IPS fail-closed | đúng hành vi đã công bố | [ ] |
| T-11 | SSH brute force | ban ≤ 5′, unban đúng hạn | [ ] |
| T-12 | WAF false positive | 15 request hợp lệ → 0 block sai | [ ] |
| T-13 | DB failover + PITR | RTO ≤ 40 s, RPO = 0, restore theo timestamp | [ ] |
| T-14 | Cấm egress + chống flood | reverse shell thất bại; VIP sống | [ ] |

## 7. Lưu ý an toàn

- **Không commit trước khi `make gitleaks` xanh.** `config.xml` của OPNsense chứa hash mật
  khẩu và key CARP; nếu lọt vào history thì phải rewrite + rotate toàn bộ key.
- **Đừng bật `--advertise-routes` / IP forwarding trên Windows.** ProxyJump đã đủ; đây là
  hố thời gian đã được ghi nhận.
- **Tailscale hết hạn key sau 180 ngày** → tắt expiry ngay ngày 1, nếu không sẽ mất quyền
  điều khiển giữa kỳ.
- Trước mỗi phép đo timing: kiểm `tailscale status` là `direct` hay `DERP`, ghi vào biên bản.
  Số liệu đo qua DERP không được dùng để tuyên bố RTO.
- Đường quản trị **không đi qua firewall** (out-of-band, như console/IPMI). Nói rõ trong báo
  cáo thay vì để hội đồng phát hiện.

## 8. Tài liệu

[interfaces.md](docs/interfaces.md) ·
[architecture.md](docs/architecture.md) ·
[decisions.md](docs/decisions.md) ·
[policy-model.md](docs/policy-model.md) ·
[mitre-map.md](docs/mitre-map.md) ·
[evidence-index.md](docs/evidence-index.md) ·
[runbooks/](docs/runbooks)
