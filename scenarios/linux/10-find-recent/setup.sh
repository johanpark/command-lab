#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A="$H/app-config"
mkdir -p "$A"/{nginx/sites,db,cache,auth,mail,queue,plugins/{seo,search,payments},empty-dir}
confs=(nginx/nginx.conf nginx/sites/default.conf nginx/sites/api.conf db/postgres.conf db/replica.conf
       cache/redis.conf auth/oauth.conf auth/session.conf mail/smtp.conf queue/worker.conf
       plugins/seo/seo.conf plugins/search/search.conf plugins/payments/payments.conf)
for f in "${confs[@]}"; do
  printf '# %s\nenabled = true\ntimeout = %d\n' "$f" "$(rand_int 5 60)" > "$A/$f"
  touch -d "$(rand_int 10 120) days ago" "$A/$f"
done
# 최근에 바뀐 .conf 2~3개 (무작위)
n=$(rand_int 2 3)
: > /opt/cmdlab/secret/changed
for f in $(printf '%s\n' "${confs[@]}" | shuf -n "$n"); do
  echo "timeout = 0   # 임시로 바꿈" >> "$A/$f"
  touch -d "$(rand_int 1 20) hours ago" "$A/$f"
  echo "$f" >> /opt/cmdlab/secret/changed
done
# 함정: 최근에 바뀌었지만 .conf 가 아닌 파일
echo "backup" > "$A/db/postgres.conf.bak"; touch -d "3 hours ago" "$A/db/postgres.conf.bak"
echo "log" > "$A/nginx/access.log"; touch -d "1 hours ago" "$A/nginx/access.log"
# 빈 파일들 (일부는 오래됨, 일부는 .conf)
for f in cache/.keep plugins/seo/TODO mail/blacklist.conf queue/dead-letter.txt auth/old.conf; do
  : > "$A/$f"; touch -d "$(rand_int 2 90) days ago" "$A/$f"
done
give "$A"
find "$A" -type f -size +0 | sort > /opt/cmdlab/secret/nonempty
