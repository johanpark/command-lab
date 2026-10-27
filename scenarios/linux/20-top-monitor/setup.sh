#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
cpu=$(rand_pick report-builder thumb-gen log-compactor)
mem=$(rand_pick image-cache session-store search-index)
secret_set cpu "$cpu"; secret_set mem "$mem"
# CPU: 4초 바쁘고 2초 쉬기를 반복
printf '#!/bin/bash\nwhile :; do end=$((SECONDS + 4)); while [ $SECONDS -lt $end ]; do :; done; sleep 2; done\n' > "/usr/local/bin/$cpu"
chmod 755 "/usr/local/bin/$cpu"
# 메모리: perl 을 이름만 바꿔 복사해서 큰 문자열을 붙잡고 있게 한다 (CPU 는 거의 안 씀)
cp /usr/bin/perl "/usr/local/bin/$mem"
for n in web-server queue-worker; do printf '#!/bin/bash\nwhile :; do sleep 30; done\n' > "/usr/local/bin/$n"; chmod 755 "/usr/local/bin/$n"; done
spawn_bg /usr/local/bin/web-server
spawn_bg /usr/local/bin/queue-worker
spawn_bg "/usr/local/bin/$mem" -e '$x = "x" x 100_000_000; sleep 86400 while 1'
spawn_bg "/usr/local/bin/$cpu"
sleep 2
