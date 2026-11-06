# 설명: main 을 reset --hard 로 되돌리면 커밋 안 한 수정까지 날아간다
# 실패해야: 만료일 TODO
cd ~/shop
git branch feature/coupon
git reset -q --hard origin/main
git switch -q feature/coupon
