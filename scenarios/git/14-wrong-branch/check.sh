#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/shop"; g() { git -C "$R" "$@"; }
tip=$(cat /opt/cmdlab/secret/tip); origin=$(cat /opt/cmdlab/secret/origin); wip=$(cat /opt/cmdlab/secret/wip)
expect "main 이 origin/main 과 같은 위치다" test "$(g rev-parse -q --verify main 2>/dev/null)" = "$origin"
f=$(g rev-parse -q --verify feature/coupon 2>/dev/null)
if [ -n "$f" ] && g merge-base --is-ancestor "$tip" "$f" 2>/dev/null; then pass "feature/coupon 에 쿠폰 커밋 3개가 있다"
elif [ -n "$f" ]; then fail "feature/coupon 에 쿠폰 커밋 3개가 있다 ($(g rev-list --count "$origin..$f" 2>/dev/null)개만 있어요)"
else fail "feature/coupon 에 쿠폰 커밋 3개가 있다 (브랜치가 없어요)"; fi
expect "origin 은 그대로다 (push 하지 않았다)" test "$(git -C "$H/remote/shop.git" rev-parse main 2>/dev/null)" = "$origin"
if grep -qxF "$wip" "$R/coupon.js" 2>/dev/null || { [ -n "$f" ] && g show "$f:coupon.js" 2>/dev/null | grep -qxF "$wip"; }; then
  pass "커밋 안 했던 coupon.js 수정(만료일 TODO)이 살아 있다"
else fail "커밋 안 했던 coupon.js 수정(만료일 TODO)이 살아 있다 (reset --hard 로 날렸나요? git stash list 도 확인해 보세요)"; fi
expect "지금 feature/coupon 브랜치에 있다" test "$(g branch --show-current 2>/dev/null)" = feature/coupon
finish
