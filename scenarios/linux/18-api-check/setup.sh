#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
W=/srv/www; mkdir -p "$W/api"
echo '{"status":"ok"}' > "$W/api/health.json"
echo "{\"version\":\"2.$(rand_int 0 9).$(rand_int 0 30)\"}" > "$W/api/version.json"
echo '[{"id":1,"item":"키보드","total":32000},{"id":2,"item":"마우스","total":15000}]' > "$W/api/orders.json"
echo '[{"id":1,"name":"모니터","price":210000}]' > "$W/api/products.json"
echo '{"theme":"dark","lang":"ko"}' > "$W/api/settings.json"
# 사용자 목록 (admin 은 무작위 2~4명)
names=(minsu jiyeon hoon sora taeho yuna dongwook eunji jaehyun hana)
: > /opt/cmdlab/secret/admins
{
  echo "["
  for i in "${!names[@]}"; do
    n=${names[$i]}
    role=$(rand_pick viewer viewer editor viewer admin)
    [ "$i" -eq 3 ] && role=admin
    [ "$role" = admin ] && echo "$n@company.kr" >> /opt/cmdlab/secret/admins
    sep=$([ "$i" -lt $((${#names[@]} - 1)) ] && echo , || true)
    printf '  {"id": %d, "name": "%s", "email": "%s@company.kr", "role": "%s", "active": %s}%s\n' \
      $((i + 1)) "$n" "$n" "$role" "$(rand_pick true true false)" "$sep"
  done
  echo "]"
} > "$W/api/users.json"
# 고장 난 주소 하나 (파일이 없어서 404)
broken=$(rand_pick orders products settings version)
rm "$W/api/$broken.json"
secret_set broken "/api/$broken.json"
for e in health users orders products settings version; do echo "http://localhost:8000/api/$e.json"; done > "$H/endpoints.txt"
give "$H/endpoints.txt"
busybox httpd -p 127.0.0.1:8000 -h "$W" >/dev/null 2>&1 < /dev/null
for i in $(seq 1 20); do curl -s -o /dev/null http://localhost:8000/api/health.json && break; sleep 0.2; done
