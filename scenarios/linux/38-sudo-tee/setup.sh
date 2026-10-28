#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p /etc/app
{
  echo "# 접근 허용 IP 목록 (한 줄에 하나)"
  echo "10.0.0.0/8"
  for i in $(seq 1 $(rand_int 4 7)); do echo "198.51.100.$(rand_int 2 250)"; done
  echo "192.168.$(rand_int 0 9).0/24"
} | awk '!seen[$0]++' > /etc/app/allowed_ips
chmod 644 /etc/app/allowed_ips
rm -f /etc/app/maintenance.conf
cp /etc/app/allowed_ips /opt/cmdlab/secret/orig
ip1="203.0.113.$(rand_int 2 120)"; ip2="203.0.113.$(rand_int 121 250)"
printf '%s\n%s\n' "$ip1" "$ip2" > /opt/cmdlab/secret/new
cat > "$H/request.txt" <<REQ
[요청] 새 사무실 IP 허용 부탁드립니다

- 판교 사무실: $ip1
- 강남 사무실: $ip2

오늘 밤 06:00 까지 점검 공지도 같이 걸어 주세요.
REQ
give "$H/request.txt"
