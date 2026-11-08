#!/usr/bin/env bash
# Kiem tra nhanh LB-A + web (Site A). Chay tren LB-A hoac Test-Client.
# Usage:
#   STATS_PASS='<mat-khu-stats>' bash check_lb.sh
# Khong hardcode mat khau trong script.

VIP=172.20.21.100
LB=172.20.21.10
WEB_A=172.20.21.20
WEB_B=172.20.21.30
STATS_USER=admin
STATS_PASS="${STATS_PASS:-__DAT_MAT_KHAU_STATS_QUA_BIEN_MOI_TRUONG__}"

echo "== Health endpoint tren backend (ky vong 200) =="
for ip in "$WEB_A" "$WEB_B"; do
  printf '%s /healthz -> ' "$ip"
  curl -s -o /dev/null -w '%{http_code}\n' --max-time 3 "http://$ip/healthz"
done

echo "== Round-robin qua VIP HTTPS (ky vong luan phien Web-A/Web-B) =="
for i in 1 2 3 4 5 6; do curl -sk --max-time 3 "https://$VIP"; done

echo "== Stats co mat khau (ky vong 200) =="
curl -s -o /dev/null -w '%{http_code}\n' --max-time 3 -u "$STATS_USER:$STATS_PASS" "http://$LB:8404/stats"

echo "== Stats khong mat khau (ky vong 401) =="
curl -s -o /dev/null -w '%{http_code}\n' --max-time 3 "http://$LB:8404/stats"