#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/shop"
mkdir -p "$R"; give "$R"
wip="// TODO: 쿠폰 할인 $(rand_int 5 30)% 적용 (작업 중)"
secret_set wip "$wip"
as_learner bash -s <<SCRIPT
set -e
cd "$R"
git init -q
printf 'export const TAX_RATE = 0.01;\nexport const withTax = (p) => p * (1 + TAX_RATE);\n' > price.js
printf 'export const cart = [];\nexport const add = (item) => cart.push(item);\n' > cart.js
git add . && git commit -qm "쇼핑몰 초기 버전" --date="2026-10-01T10:00:00"
git switch -qc feature/coupon
printf 'export const applyCoupon = (total, rate) => total * (1 - rate);\n' >> cart.js
git commit -qam "쿠폰 함수 뼈대" --date="2026-10-20T10:00:00"
printf '%s\n' "$wip" >> cart.js
SCRIPT
git -C "$R" rev-parse main > /opt/cmdlab/secret/main
git -C "$R" rev-parse feature/coupon > /opt/cmdlab/secret/feature
