#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/shop"; g() { git -C "$R" "$@"; }
rel0=$(secret_get release)
expect "main 은 그대로다" test "$(g rev-parse main 2>/dev/null)" = "$(secret_get main)"
expect "release/1.0 의 원래 커밋 위에 쌓였다" test "$(g rev-parse 'release/1.0^' 2>/dev/null)" = "$rel0"
n=$(g rev-list --count "$rel0..release/1.0" 2>/dev/null)
[ "$n" = 1 ] && pass "release/1.0 에 커밋이 딱 하나 늘었다" || fail "release/1.0 에 커밋이 딱 하나 늘었다 (지금: ${n:-?}개)"
if g show release/1.0:login.js 2>/dev/null | cmp -s - /opt/cmdlab/secret/login.js; then pass "release/1.0 에 보안 수정(login.js)이 들어갔다"
else fail "release/1.0 에 보안 수정(login.js)이 들어갔다"; fi
expect "개발 중인 기능(coupon.js, recommend.js)은 release/1.0 에 없다" bash -c "! git -C '$R' cat-file -e release/1.0:coupon.js 2>/dev/null && ! git -C '$R' cat-file -e release/1.0:recommend.js 2>/dev/null"
expect "git status 가 깨끗하다 (cherry-pick 진행 중 아님)" bash -c "[ -z \"\$(git -C '$R' status --porcelain)\" ] && [ ! -e '$R/.git/CHERRY_PICK_HEAD' ]"
finish
