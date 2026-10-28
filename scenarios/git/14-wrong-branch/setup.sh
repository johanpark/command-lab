#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
rm -rf "$H/shop" "$H/remote"; mkdir -p "$H/remote"; give "$H/remote"
pct=$(rand_int 5 30)
as_learner bash -s <<SCRIPT
set -e
cd ~/remote
git init -q --bare -b main shop.git
git clone -q shop.git ~/shop 2>/dev/null
cd ~/shop
c() { GIT_AUTHOR_DATE="\$1" GIT_COMMITTER_DATE="\$1" git commit -qm "\$2"; }
echo "# shop" > README.md; echo "export const cart = [];" > cart.js
git add . && c "2026-10-01T10:00:00" "쇼핑몰 시작"
echo "export const pay = () => {};" > pay.js
git add . && c "2026-10-10T10:00:00" "결제 모듈"
git push -q origin main 2>/dev/null
echo "export function coupon(code) {}" > coupon.js
git add . && c "2026-10-28T09:10:00" "쿠폰: 기본 구조"
echo "export const COUPON_RATE = $pct;" >> coupon.js
git commit -qam "쿠폰: 할인율 설정" --date="2026-10-28T09:40:00"
echo "import { coupon } from './coupon.js';" >> cart.js
git commit -qam "쿠폰: 장바구니에 연결" --date="2026-10-28T10:20:00"
echo "// TODO: 만료일 검사 ($pct% 쿠폰)" >> coupon.js
SCRIPT
git -C "$H/shop" rev-parse HEAD > /opt/cmdlab/secret/tip
git -C "$H/shop" rev-parse origin/main > /opt/cmdlab/secret/origin
tail -n 1 "$H/shop/coupon.js" > /opt/cmdlab/secret/wip
