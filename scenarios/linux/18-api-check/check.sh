#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
got=$(answer | sed -E 's#^https?://(localhost|127\.0\.0\.1)(:8000)?##')
if [ "$got" = "$(secret_get broken)" ]; then pass "answer.txt 에 고장 난(200 이 아닌) 주소를 적었다"
else fail "answer.txt 에 고장 난(200 이 아닌) 주소를 적었다 (지금 적힌 값: '$(answer)')"; fi
if [ ! -f "$H/admins.txt" ]; then
  fail "~/admins.txt 에 admin 사용자 email 이 모두 있다 (파일이 없어요)"
else
  g=$(tr -d '\r"' < "$H/admins.txt" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d' | sort)
  w=$(sort /opt/cmdlab/secret/admins)
  if [ "$g" = "$w" ]; then pass "~/admins.txt 에 admin 사용자 email 이 모두 있다 ($(echo "$w" | wc -l)명)"
  else fail "~/admins.txt 에 admin 사용자 email 이 모두 있다 (기대 $(echo "$w" | wc -l)명, 지금 $(echo "$g" | sed '/^$/d' | wc -l)줄)"; fi
fi
finish
