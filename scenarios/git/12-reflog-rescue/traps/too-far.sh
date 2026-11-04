# 설명: reflog 를 한 칸 더 거슬러 reset 하면 그 전 상태로 간다
# 실패해야: main 이 reset 직전 커밋
cd ~/app
git reset -q --hard 'main@{2}'
