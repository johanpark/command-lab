# 설명: main 만 되살리고 지운 브랜치는 그대로 둔다
# 실패해야: feature/payment 가 삭제 직전
cd ~/app
git reset -q --hard 'main@{1}'
