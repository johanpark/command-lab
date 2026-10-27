#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "changed.txt 에 값이 바뀐 설정 이름을 적었다" "$(secret_get key)" "$H/changed.txt"
F="$H/dormant.txt"
if [ ! -f "$F" ]; then fail "dormant.txt 에 휴면 아이디가 정렬·중복 없이 있다 (파일이 없어요)"
else
  got=$(tr -d '\r' < "$F" | sed -e 's/[[:space:]]*$//' -e '/^$/d')
  want=$(cat /opt/cmdlab/secret/dormant)
  if [ "$got" = "$want" ]; then pass "dormant.txt 에 휴면 아이디가 정렬·중복 없이 있다 ($(echo "$want" | wc -l)명)"
  elif [ "$(echo "$got" | sort -u)" = "$want" ]; then fail "dormant.txt 에 휴면 아이디가 정렬·중복 없이 있다 (내용은 맞는데 정렬이 안 됐거나 중복이 있어요)"
  else fail "dormant.txt 에 휴면 아이디가 정렬·중복 없이 있다 (기대 $(echo "$want" | wc -l)명, 지금 $(echo "$got" | wc -l)줄 — comm 전에 sort 했나요?)"; fi
fi
finish
