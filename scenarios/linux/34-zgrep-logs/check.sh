#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
f=$(secret_get file)
got=$(answer); got=${got##*/}
[ "$got" = "$f" ] && pass "answer.txt 에 에러가 있는 로그 파일 이름을 적었다" || fail "answer.txt 에 에러가 있는 로그 파일 이름을 적었다 (지금 적힌 값: '$(answer)')"
if [ ! -f "$H/incident.txt" ]; then fail "incident.txt 에 에러 줄과 바로 앞 2줄이 있다 (파일이 없어요)"
else
  # 여러 파일을 대상으로 찾아 '파일이름-' / '파일이름:' 접두어가 붙었으면 떼고 비교
  got=$(tr -d '\r' < "$H/incident.txt" | sed -e "s#^.*$f[-:]##" -e '/^--$/d' -e '/^$/d')
  [ "$got" = "$(cat /opt/cmdlab/secret/incident)" ] && pass "incident.txt 에 에러 줄과 바로 앞 2줄이 있다" \
    || fail "incident.txt 에 에러 줄과 바로 앞 2줄이 있다 (지금 $(echo "$got" | wc -l)줄 — grep -B 2)"
fi
finish
