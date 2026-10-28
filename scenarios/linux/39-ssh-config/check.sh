#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
{ read -r web_ip; read -r web_user; read -r web_port; read -r db_ip; read -r db_user; } < /opt/cmdlab/secret/servers
mode=$(stat -c %a "$H/.ssh/config" 2>/dev/null)
if [ -n "$mode" ] && [ $(( 8#$mode & 8#022 )) -eq 0 ]; then pass "config 를 다른 사람이 쓸 수 없다 (지금: $mode)"
else fail "config 를 다른 사람이 쓸 수 없다 (지금: ${mode:-없음} — chmod 600)"; fi
G() { as_learner ssh -G "$1" 2>/dev/null | awk -v k="$2" '$1 == k { print $2; exit }'; }
got="$(G web hostname) $(G web user) $(G web port) $(G web identityfile | sed "s|^$H|~|")"
want="$web_ip $web_user $web_port ~/.ssh/web_key"
[ "$got" = "$want" ] && pass "ssh web 설정이 맞다 ($want)" || fail "ssh web 설정이 맞다 (ssh -G web: '$got', 기대: '$want')"
got="$(G db hostname) $(G db user) $(G db port) $(G db identityfile | sed "s|^$H|~|")"
want="$db_ip $db_user 22 ~/.ssh/db_key"
[ "$got" = "$want" ] && pass "ssh db 설정이 맞다 ($want)" || fail "ssh db 설정이 맞다 (ssh -G db: '$got', 기대: '$want')"
expect "bastion 별칭이 그대로 동작한다" test "$(G bastion hostname) $(G bastion user)" = "10.0.0.5 admin"
expect "공통 ServerAliveInterval 60 이 모든 서버에 적용된다" test "$(G web serveraliveinterval) $(G db serveraliveinterval) $(G bastion serveraliveinterval)" = "60 60 60"
finish
