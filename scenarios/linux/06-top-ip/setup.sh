#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
gawk -v seed="$RANDOM" '
BEGIN {
  srand(seed)
  for (i = 0; i < 40; i++) ip[i] = sprintf("%d.%d.%d.%d", 1+int(rand()*222), int(rand()*255), int(rand()*255), 1+int(rand()*253))
  bad = ip[int(rand()*40)]
  split("/ /index.html /login /api/items /api/cart /static/app.js /static/style.css /favicon.ico", path, " ")
  split("200 200 200 200 304 404 500", code, " ")
  t = 1761354000
  n = 3000 + int(rand()*1500)
  for (i = 0; i < n; i++) {
    t += int(rand()*3)
    r = rand()
    # 공격 IP는 /login 을 집중적으로 두드린다. 2~5위는 비슷비슷하게.
    if (r < 0.18) { who = bad; p = "/login"; c = 401 }
    else { k = int(rand()*rand()*40); who = ip[k]; p = path[1+int(rand()*8)]; c = code[1+int(rand()*7)] }
    printf "%s - - [%s] \"GET %s HTTP/1.1\" %s %d\n", who, strftime("%d/%b/%Y:%H:%M:%S +0900", t), p, c, 100+int(rand()*9000)
  }
}' > "$H/access.log"
give "$H/access.log"
awk '{print $1}' "$H/access.log" | sort | uniq -c | sort -rn > /opt/cmdlab/secret/ranking
head -n 1 /opt/cmdlab/secret/ranking | awk '{print $2}' > /opt/cmdlab/secret/top
