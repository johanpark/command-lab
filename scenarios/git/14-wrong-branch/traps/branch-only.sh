# 설명: 브랜치만 만들고 main 은 그대로 두면 main 에 쿠폰 커밋이 남는다
# 실패해야: main 이 origin/main 과 같은 위치
cd ~/shop
git switch -q -c feature/coupon
