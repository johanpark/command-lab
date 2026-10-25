#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/shop-api"
mkdir -p "$R/src"
give "$R"
pw="P@ss-$(rand_int 1000 9999)"
as_learner bash -s <<SCRIPT
set -e
cd "$R"
git init -q
printf 'node_modules/\n*.log\n' > .gitignore
echo "# shop-api" > README.md
echo "module.exports = { listItems() {} };" > src/items.js
git add . && git commit -qm "프로젝트 시작" --date="2026-10-20T10:00:00"
echo "module.exports = { getCart() {} };" > src/cart.js
git add . && git commit -qm "장바구니 API" --date="2026-10-22T15:30:00"
echo "module.exports = { createOrder() {} };" > src/orders.js
printf 'DB_HOST=db.internal\nDB_PASSWORD=$pw\n' > .env
git add . && git commit -qm "주문 API 추가"
SCRIPT
git -C "$R" log --format=%H -n 1 HEAD~1 > /opt/cmdlab/secret/parent
