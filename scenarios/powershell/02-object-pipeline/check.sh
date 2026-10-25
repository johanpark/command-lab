#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 매출 합계 1위 지역을 적었다" "$(secret_get top)"
F="$H/big-orders.csv"
if [ ! -f "$F" ]; then
  fail "~/big-orders.csv 에 500 이상 주문만 있다 (파일이 없어요)"
else
  # Export-Csv 는 값을 따옴표로 감싼다 → 따옴표/CR 제거 후 id 열 비교
  clean=$(tr -d '"\r' < "$F")
  header=$(echo "$clean" | head -n 1)
  col=$(echo "$header" | tr ',' '\n' | grep -nx 'id' | cut -d: -f1)
  if [ -z "$col" ]; then
    fail "~/big-orders.csv 에 500 이상 주문만 있다 (id 열이 없어요: 원본과 같은 열로 저장했나요?)"
  else
    got=$(echo "$clean" | tail -n +2 | cut -d, -f"$col" | sed '/^$/d' | sort)
    want=$(cat /opt/cmdlab/secret/big-ids)
    if [ "$got" = "$want" ]; then
      pass "~/big-orders.csv 에 500 이상 주문만 있다 ($(echo "$want" | wc -l)건)"
    else
      fail "~/big-orders.csv 에 500 이상 주문만 있다 (기대 $(echo "$want" | wc -l)건, 지금 $(echo "$got" | sed '/^$/d' | wc -l)건 — 숫자 비교가 맞는지 확인)"
    fi
  fi
  expect "big-orders.csv 의 열이 원본과 같다 (id,date,region,product,amount)" test "$header" = "id,date,region,product,amount"
fi
finish
