#!/usr/bin/env bash
# ==============================================================================
# transit-b-setup.sh — Cấu hình Linux Transit-B (Site B - Minh Hùng)
# IP: 172.20.20.6/24 | Advertise: 172.20.20.0/24, 172.20.40.0/24, 172.20.50.0/24
# ponytail: Dùng static route + nftables cục bộ cho lab 2 site; nâng cấp lên FRR (OSPF/BGP) khi có >= 3 site hoặc cần dynamic failover route.
# ==============================================================================
set -euo pipefail
export PATH="$PATH:/usr/sbin:/sbin"

TRANSIT_IP="172.20.20.6/24"
FIREWALL_GW="172.20.20.1"
LAN_IF="${LAN_IF:-eth0}"
TS_IF="${TS_IF:-tailscale0}"
ADVERTISE_ROUTES="172.20.20.0/24,172.20.40.0/24,172.20.50.0/24"
TS_TAG="${TS_TAG:-tag:transit-b}"

# Input validation tại trust boundary
validate_inputs() {
  if [[ ! "${LAN_IF}" =~ ^[a-zA-Z0-9_.-]+$ ]] || [[ ! "${TS_IF}" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    echo "[ERROR] Tên interface không hợp lệ: LAN_IF=${LAN_IF}, TS_IF=${TS_IF}" >&2
    exit 1
  fi
  if [[ "${TRANSIT_IP}" != "172.20.20.6/24" ]]; then
    echo "[ERROR] TRANSIT_IP sai chuẩn thiết kế (yêu cầu 172.20.20.6/24)" >&2
    exit 1
  fi
  if [[ ! "${TS_TAG}" =~ ^tag:[a-z0-9-]+$ ]]; then
    echo "[ERROR] TS_TAG không hợp lệ: ${TS_TAG}" >&2
    exit 1
  fi
}

generate_nftables_conf() {
  cat <<EOF
#!/usr/sbin/nft -f
flush ruleset

table inet transit_filter {
  chain input {
    type filter hook input priority 0; policy drop;

    iifname "lo" accept
    ct state established,related accept
    ct state invalid drop

    # Cho phép ICMP kiểm tra kết nối và Tailscale WireGuard UDP
    ip protocol icmp accept
    udp dport 41641 accept

    # SSH quản trị chỉ từ MGMT (172.20.50.0/24), DMZ nội bộ (172.20.20.0/24) hoặc qua Tailscale ACL
    iifname "${LAN_IF}" ip saddr { 172.20.20.0/24, 172.20.50.0/24 } tcp dport 22 accept
    iifname "${TS_IF}" tcp dport 22 accept

    log prefix "[TRANSIT-B-INPUT-DROP] " counter drop
  }

  chain forward {
    type filter hook forward priority 0; policy drop;

    ct state established,related accept
    ct state invalid drop

    # Chống bypass Firewall #1: Cấm đẩy lưu lượng Tailscale sang bất kỳ card mạng phụ nào
    # ngoài LAN_IF (DMZ -> Firewall-A 172.20.20.1). Ngăn việc gắn nhầm VMnet40/50 trực tiếp lên Transit-B.
    iifname "${TS_IF}" oifname != "${LAN_IF}" \
      log prefix "[TRANSIT-B-BYPASS-DROP] " counter drop

    # Chống bypass Firewall #2: Cấm tuyệt đối nguồn WAN-LAB (172.20.10.0/24) đi xuyên qua Transit-B vào DB/MGMT
    ip saddr 172.20.10.0/24 ip daddr { 172.20.40.0/24, 172.20.50.0/24 } \
      log prefix "[TRANSIT-B-WAN-BYPASS-DROP] " counter drop

    # Chống bypass Firewall #3: Giới hạn đúng giao thức/cổng trước khi chuyển tiếp tới Firewall-A (172.20.20.1)
    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr 172.20.20.0/24 ip protocol icmp accept
    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr 172.20.20.0/24 tcp dport { 80, 443 } accept

    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr { 172.20.40.11, 172.20.40.12 } ip protocol icmp accept
    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr { 172.20.40.11, 172.20.40.12 } tcp dport { 5432, 3306 } accept

    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr 172.20.50.0/24 ip protocol icmp accept
    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr 172.20.50.0/24 tcp dport { 22, 514 } accept
    iifname "${TS_IF}" oifname "${LAN_IF}" ip daddr 172.20.50.10 udp dport 514 accept

    # Chiều từ mạng nội bộ Site B (sau khi qua Firewall-A) đi sang Site A qua Tailscale
    iifname "${LAN_IF}" oifname "${TS_IF}" ip saddr { 172.20.20.0/24, 172.20.40.0/24, 172.20.50.0/24 } accept

    log prefix "[TRANSIT-B-FWD-DROP] " counter drop
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
EOF
}

# Chế độ tự kiểm tra (Runnable self-check không cần quyền root)
if [[ "${1:-}" == "--self-check" ]]; then
  validate_inputs
  NFT_OUT="$(generate_nftables_conf)"
  [[ "${TRANSIT_IP}" == "172.20.20.6/24" ]] || { echo "FAIL: IP mismatch"; exit 1; }
  [[ "${ADVERTISE_ROUTES}" == "172.20.20.0/24,172.20.40.0/24,172.20.50.0/24" ]] || { echo "FAIL: routes mismatch"; exit 1; }
  grep -q "TRANSIT-B-BYPASS-DROP" <<<"${NFT_OUT}" || { echo "FAIL: missing anti-bypass rule"; exit 1; }
  grep -q "5432, 3306" <<<"${NFT_OUT}" || { echo "FAIL: missing DB port filter"; exit 1; }
  echo "[PASS] transit-b-setup.sh self-check OK"
  exit 0
fi

validate_inputs

if [[ "${EUID}" -ne 0 ]]; then
  echo "[ERROR] Vui lòng chạy script với quyền root (sudo)." >&2
  exit 1
fi

# Đảm bảo Transit-B không gắn trực tiếp interface vào mạng DATABASE (172.20.40.0/24)
if ip -o -4 addr show | grep -v " ${LAN_IF} " | grep -qE "172\.20\.(40|50)\."; then
  echo "[ERROR] Phát hiện interface gắn trực tiếp vào DATABASE/MGMT gây nguy cơ bypass Firewall-A!" >&2
  exit 1
fi

echo "[1/4] Cấu hình IP tĩnh ${TRANSIT_IP} trên ${LAN_IF} và định tuyến qua Firewall-A (${FIREWALL_GW})..."
ip link set "${LAN_IF}" up
ip addr replace "${TRANSIT_IP}" dev "${LAN_IF}"
ip route replace 172.20.40.0/24 via "${FIREWALL_GW}" dev "${LAN_IF}"
ip route replace 172.20.50.0/24 via "${FIREWALL_GW}" dev "${LAN_IF}"

echo "[2/4] Bật IPv4 Forwarding (net.ipv4.ip_forward=1)..."
cat >/etc/sysctl.d/99-transit-b.conf <<EOF
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
EOF
sysctl --system >/dev/null

echo "[3/4] Áp dụng bộ lọc nftables chống bypass firewall..."
generate_nftables_conf >/etc/nftables.conf
nft -f /etc/nftables.conf
systemctl enable --now nftables

echo "[4/4] Khởi chạy Tailscale subnet router trên Transit-B..."
TS_ARGS=(
  "up"
  "--advertise-routes=${ADVERTISE_ROUTES}"
  "--accept-routes"
  "--advertise-tags=${TS_TAG}"
)

# Không lưu secret thật trong file: truyền TS_AUTHKEY qua môi trường lúc chạy nếu dùng headless auth
if [[ -n "${TS_AUTHKEY:-}" ]]; then
  TS_ARGS+=("--authkey=${TS_AUTHKEY}")
fi

tailscale "${TS_ARGS[@]}"

echo "[DONE] Transit-B (${TRANSIT_IP}) đã cấu hình hoàn tất."
