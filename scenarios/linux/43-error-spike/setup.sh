#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/logs"
gawk -v seed="$RANDOM" '
BEGIN {
  srand(seed)
  split("/api/orders /api/pay /api/cart /api/items /index.html /static/app.js", path, " ")
  split("GET GET GET POST", meth, " ")
  spike = 13 * 60 + int(rand() * 180)          # 13:00 ~ 15:59 사이 한 분
  do { bot = 9 * 60 + int(rand() * 600) } while (bot >= spike - 30 && bot <= spike + 30)   # 404 폭주는 다른 시각
  for (m = 0; m < 24 * 60; m++) {
    n = 2 + int(rand() * 4)
    for (k = 0; k < n; k++) emit(m, pick5xx(m, 0.01))
    if (m == spike) for (k = 0; k < 25 + int(rand() * 15); k++) emit(m, 500 + 2 * int(rand() * 2) + (rand() < 0.3))
    if (m >= spike - 3 && m <= spike + 3 && m != spike) for (k = 0; k < 3 + int(rand() * 5); k++) emit(m, 502)
    if (m == bot) for (k = 0; k < 60 + int(rand() * 20); k++) emit(m, 404)
  }
}
function pick5xx(m, p) { r = rand(); return r < p ? 500 : (r < 0.06 ? 404 : (r < 0.1 ? 304 : 200)) }
function emit(m, code) {
  s = int(rand() * 60)
  ms = (code >= 500) ? 1000 + int(rand() * 3000) : 5 + int(rand() * 495)
  pth = (code == 404) ? "/wp-login.php" : path[1 + int(rand() * 6)]
  printf "%s.%06d %s %s %d %dms\n", sprintf("2026-10-28T%02d:%02d:%02d+09:00", int(m / 60), m % 60, s), rand() * 1000000, meth[1 + int(rand() * 4)], pth, code, ms
}' | sort | sed -E 's/\.[0-9]{6}//' > "$H/logs/access.log"
give "$H/logs"
L="$H/logs/access.log"
awk '$4 >= 500' "$L" | cut -c12-16 | sort | uniq -c | sort -rn | head -n 2 > /opt/cmdlab/secret/top2
awk '$4 >= 500' "$L" | cut -c12-13 | sort | uniq -c | awk '{print $2, $1}' > /opt/cmdlab/secret/by_hour
