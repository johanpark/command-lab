#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
cpu=$(rand_pick stuck-export batch-report pdf-render)
mem=$(rand_pick cache-server memo-store blob-cache)
secret_set cpu "$cpu"; secret_set mem "$mem"
printf '#!/bin/bash\nwhile :; do :; done\n' > "/usr/local/bin/$cpu"; chmod 755 "/usr/local/bin/$cpu"
cp /usr/bin/perl "/usr/local/bin/$mem"
printf '#!/bin/bash\nwhile :; do sleep 30; done\n' > /usr/local/bin/web-api; chmod 755 /usr/local/bin/web-api
spawn_bg /usr/local/bin/web-api
# perl 을 이름만 바꿔 복사해서 큰 문자열을 붙잡고 있게 한다 (pwsh 자신보다 크게, CPU 는 거의 안 씀)
spawn_bg "/usr/local/bin/$mem" -e '$x = "x" x 150_000_000; sleep 86400 while 1'
spawn_bg "/usr/local/bin/$cpu"
sleep 3
