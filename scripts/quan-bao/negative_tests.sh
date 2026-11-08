#!/usr/bin/env bash
# Negative test phia client (Site A). Chay tren Test-Client trong mang lab co lap.
# LUU Y: muc 1, 3 can FIREWALL cua Minh Hung de chan that su (hien chua co firewall).
# Muc 4 (DB) thuoc Minh Hung, cho DB dung moi test.
# Script khong dung set -e vi cac muc negative ky vong that bai.

VIP=172.20.21.100
WEB_A=172.20.21.20
WEB_B=172.20.21.30

echo "== 1. Web bypass: WAN vao web IP truc tiep (ky vong SAU firewall: BLOCKED + log) =="
for ip in "$WEB_A" "$WEB_B"; do
  printf 'http://%s -> ' "$ip"
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 "http://$ip")
  if [ "$code" = "000" ]; then echo "BLOCKED/timeout"; else echo "HTTP $code (HIEN CHO PHEP - can firewall chan)"; fi
done

echo "== 2. HTTPS cert lab: khong tin cay mac dinh (ky vong: FAIL verify) =="
if curl -sS -o /dev/null --max-time 3 "https://$VIP" 2>/dev/null; then
  echo "VERIFY OK (ngoai ky vong)"
else
  echo "CERT VERIFY FAIL (dung ky vong - cert lab tu ky)"
fi

echo "== 3. SSH WAN toi web cong 22 (ky vong SAU firewall: BLOCKED; hien: key-only) =="
for ip in "$WEB_A" "$WEB_B"; do
  printf 'ssh %s:22 -> ' "$ip"
  if timeout 3 bash -c "echo > /dev/tcp/$ip/22" 2>/dev/null; then
    echo "PORT OPEN (can firewall chan tu WAN)"
  else
    echo "BLOCKED/timeout"
  fi
done

echo "== 4. DB truc tiep tu WAN (ky vong: BLOCKED + log) =="
echo "PENDING: DB-Primary/Replica + firewall thuoc Minh Hung; test sau khi trien khai."