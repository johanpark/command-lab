#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R=/srv/app/releases/2.4.0
if [ -x "$R/bin/start.sh" ] && [ "$(cat "$R/VERSION" 2>/dev/null)" = 2.4.0 ]; then pass "2.4.0 이 releases/2.4.0/bin/start.sh 위치에 풀렸다 (실행 권한 유지)"
elif [ -d "$R/app-2.4.0" ]; then fail "2.4.0 이 releases/2.4.0/bin/start.sh 위치에 풀렸다 (2.4.0/app-2.4.0/ 처럼 한 겹 더 들어갔어요 — --strip-components=1)"
elif [ -f "$R/bin/start.sh" ]; then fail "2.4.0 이 releases/2.4.0/bin/start.sh 위치에 풀렸다 (실행 권한이 없어요)"
else fail "2.4.0 이 releases/2.4.0/bin/start.sh 위치에 풀렸다 (없어요)"; fi
miss=""; while read -r f; do [ -f "$R/plugins/$f" ] || miss+="$f "; done < /opt/cmdlab/secret/plugins
[ -z "$miss" ] && pass "플러그인이 releases/2.4.0/plugins/ 에 있다" || fail "플러그인이 releases/2.4.0/plugins/ 에 있다 (없음: $miss)"
stray=""
for dir in "$H" "$H/downloads" /srv/app/releases /srv/app "$R"; do
  while read -r f; do [ -e "$dir/$f" ] && stray+="${dir/#$H/\~}/$f "; done < /opt/cmdlab/secret/plugins
done
[ -d "$H/app-2.4.0" ] && stray+="~/app-2.4.0 "; [ -d "$H/downloads/app-2.4.0" ] && stray+="~/downloads/app-2.4.0 "
[ -z "$stray" ] && pass "엉뚱한 곳에 풀린 찌꺼기가 없다" || fail "엉뚱한 곳에 풀린 찌꺼기가 없다 (남아 있음: $stray)"
expect "2.3.9 와 current 링크는 그대로다" bash -c "md5sum --quiet -c /opt/cmdlab/secret/old && [ \"\$(readlink /srv/app/current)\" = releases/2.3.9 ]"
finish
