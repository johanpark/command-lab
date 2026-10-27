#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/shop"
g() { git -C "$R" "$@"; }
main0=$(secret_get main); feat0=$(secret_get feature)
expect "main 의 price.js 에 TAX_RATE = 0.1 이 커밋됐다" bash -c "git -C '$R' show main:price.js | grep -qE 'TAX_RATE *= *0?\.1;?\$'"
if [ "$(g rev-parse 'main^' 2>/dev/null)" = "$main0" ] && [ "$(g diff --name-only "$main0" main 2>/dev/null)" = price.js ]; then
  pass "main 에는 price.js 만 바꾼 커밋 하나가 추가됐다"
else
  fail "main 에는 price.js 만 바꾼 커밋 하나가 추가됐다 (cart.js 까지 들어가거나 커밋이 여러 개면 안 돼요)"
fi
expect "feature/coupon 브랜치의 커밋은 그대로다 (작업 중 코드를 커밋하지 않음)" test "$(g rev-parse feature/coupon)" = "$feat0"
expect "지금 feature/coupon 브랜치에 있다" test "$(g branch --show-current)" = feature/coupon
expect "작업 중이던 cart.js 변경이 되살아났다" grep -qF "$(secret_get wip)" "$R/cart.js"
expect "cart.js 는 아직 커밋되지 않은 상태다" bash -c "git -C '$R' status --porcelain | grep -q 'cart.js'"
finish
