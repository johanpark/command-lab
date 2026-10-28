#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
top=$(head -n 1 /opt/cmdlab/secret/top2 | awk '{print $2}')
expect_answer "answer.txt 에 5xx 가 가장 많았던 1분(HH:MM)을 적었다" "$top"
F="$H/by_hour.txt"
if [ ! -f "$F" ]; then fail "by_hour.txt 에 시간별 5xx 개수가 시간 순서로 있다 (파일이 없어요)"
else
  got=$(tr -d '\r' < "$F" | tr -s ' \t' '  ' | sed -e 's/^ //' -e 's/ $//' -e '/^$/d')
  want=$(cat /opt/cmdlab/secret/by_hour)
  if [ "$got" = "$want" ]; then pass "by_hour.txt 에 시간별 5xx 개수가 시간 순서로 있다"
  elif [ "$(awk '{print $2, $1}' <<< "$got")" = "$want" ]; then fail "by_hour.txt 에 시간별 5xx 개수가 시간 순서로 있다 ('개수 시간' 순서예요 — 'HH 개수' 로 뒤집어 주세요)"
  elif [ "$(sort <<< "$got")" = "$(sort <<< "$want")" ]; then fail "by_hour.txt 에 시간별 5xx 개수가 시간 순서로 있다 (값은 맞는데 시간 순서가 아니에요)"
  else fail "by_hour.txt 에 시간별 5xx 개수가 시간 순서로 있다 (개수가 달라요 — 5xx 만 셌나요?)"; fi
fi
finish
