#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F=/etc/app/allowed_ips; M=/etc/app/maintenance.conf
orig=/opt/cmdlab/secret/orig
n=$(wc -l < "$orig")
if [ "$(head -n "$n" "$F" 2>/dev/null)" = "$(cat "$orig")" ]; then pass "기존 허용 목록이 그대로 남아 있다"
else fail "기존 허용 목록이 그대로 남아 있다 (지금 $(wc -l < "$F" 2>/dev/null || echo 0)줄 — tee 에 -a 를 빼먹었나요?)"; fi
ok=1
while read -r ip; do [ "$(grep -cxF "$ip" "$F" 2>/dev/null)" = 1 ] || ok=0; done < /opt/cmdlab/secret/new
[ "$ok" = 1 ] && pass "새 IP 2개가 각각 한 번씩 추가됐다" || fail "새 IP 2개가 각각 한 번씩 추가됐다 (없거나 중복 — grep 203.0.113 $F)"
expect "새 IP 는 맨 뒤에 추가됐다" test "$(tail -n +$((n + 1)) "$F" | sed '/^[[:space:]]*$/d' | sort)" = "$(sort /opt/cmdlab/secret/new)"
if [ -f "$M" ] && [ "$(tr -d '\r' < "$M" | sed -e 's/[[:space:]]*$//' -e '/^$/d')" = "$(printf 'MAINTENANCE=on\nUNTIL=06:00')" ]; then pass "maintenance.conf 내용이 정확하다"
else fail "maintenance.conf 내용이 정확하다 ($( [ -f "$M" ] && echo '내용이 달라요' || echo '파일이 없어요'))"; fi
own=$(stat -c %U "$F" "$M" 2>/dev/null | sort -u | tr '\n' ' ')
[ "$own" = "root " ] && pass "두 파일 모두 root 소유다" || fail "두 파일 모두 root 소유다 (지금: ${own:-없음})"
finish
