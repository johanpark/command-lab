# 설명: stash 대신 작업 중인 코드를 커밋해 버린다
# 실패해야: feature/coupon 브랜치의 커밋은 그대로
# 실패해야: 아직 커밋되지 않은 상태
cd ~/shop
git commit -qam "wip"
git switch -q main
sed -i 's/TAX_RATE = 0.01/TAX_RATE = 0.1/' price.js
git commit -qam "세율 버그 수정"
git switch -q feature/coupon
