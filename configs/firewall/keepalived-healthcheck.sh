#!/bin/sh
# Exit 0 only if nftables is active and IPv4 forwarding is on.
set -eu
systemctl is-active --quiet nftables
[ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]
exit 0
