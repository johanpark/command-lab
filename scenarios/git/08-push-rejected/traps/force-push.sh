# 설명: 거절됐다고 --force 로 밀면 동료의 커밋이 원격에서 사라진다
# 실패해야: 동료의 커밋이 원격 main 에 그대로
cd ~/team-app
git push -q --force
