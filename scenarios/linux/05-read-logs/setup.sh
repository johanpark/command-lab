#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/logs"
L="$H/logs/app.log"
total=$(rand_int 2500 3500)
gawk -v total="$total" -v seed="$RANDOM" '
BEGIN {
  srand(seed); t = 1761300000
  split("auth payment order cart search user", svc, " ")
  for (i = 1; i <= total; i++) {
    t += int(rand() * 5)
    s = svc[int(rand() * 6) + 1]
    r = rand()
    ts = strftime("%Y-%m-%d %H:%M:%S", t)
    if (r < 0.04)      printf "%s ERROR [%s] request failed: connection timeout (id=%d)\n", ts, s, int(rand()*99999)
    else if (r < 0.05) printf "%s ERROR [%s] database error: deadlock detected\n", ts, s
    else if (r < 0.12) printf "%s WARN  [%s] slow response %dms\n", ts, s, 500 + int(rand()*3000)
    else if (r < 0.14) printf "%s INFO  [%s] retry succeeded after previous error\n", ts, s
    else               printf "%s INFO  [%s] request ok %dms\n", ts, s, int(rand()*200)
  }
}' > "$L"
give "$H/logs"
grep -c ERROR "$L" > /opt/cmdlab/secret/count
tail -n 20 "$L" > /opt/cmdlab/secret/recent
grep ERROR "$L" > /opt/cmdlab/secret/errors
