#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
key=$(rand_pick timeout max_conn cache_ttl)
case $key in timeout) a=30 b=5;; max_conn) a=100 b=20;; cache_ttl) a=3600 b=60;; esac
secret_set key "$key"
{
  echo "# 서버 설정"; echo "host = 0.0.0.0"; echo "port = 8080"
  for k in timeout max_conn cache_ttl; do [ "$k" = "$key" ] && echo "$k = $a" || echo "$k = 10"; done
  echo "legacy_mode = on"; echo "log_level = info"
} > "$H/config-old.conf"
{
  echo "# 서버 설정"; echo "host = 0.0.0.0"; echo "port = 8080"
  for k in timeout max_conn cache_ttl; do [ "$k" = "$key" ] && echo "$k = $b" || echo "$k = 10"; done
  echo "log_level = info"; echo "metrics = enabled"
} > "$H/config-new.conf"
# 회원 목록
names=(kim lee park choi jung kang cho yoon jang lim han oh seo shin kwon hwang ahn song ryu hong)
: > "$H/active-users.txt"
for n in "${names[@]}"; do
  for i in 1 2 3; do echo "$n$i$(rand_int 0 9)"; done
done | sort -u | shuf > /tmp/all
cp /tmp/all "$H/all-users.txt"; shuf -n 15 /tmp/all >> "$H/all-users.txt"   # 중복 섞기
shuf -n $(( $(wc -l < /tmp/all) * 2 / 3 )) /tmp/all > "$H/active-users.txt"
echo "guest01" >> "$H/active-users.txt"     # 전체 목록에 없는 아이디도 하나
give "$H"/config-*.conf "$H/all-users.txt" "$H/active-users.txt"
comm -23 <(sort -u "$H/all-users.txt") <(sort -u "$H/active-users.txt") > /opt/cmdlab/secret/dormant
rm -f /tmp/all
