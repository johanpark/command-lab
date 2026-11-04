# 설명: stash 없이 main 으로 가서 commit -a 하면 cart.js 변경까지 main 에 들어간다
# 실패해야: price.js 만 바꾼 커밋 하나
cd ~/shop
git switch -q main 2>/dev/null || git checkout -q main
sed -i 's/TAX_RATE = 0.01/TAX_RATE = 0.1/' price.js
git commit -qam "세율 버그 수정"
git switch -q feature/coupon
