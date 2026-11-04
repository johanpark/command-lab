# 설명: 충돌이 무서워 merge --abort 하면 합쳐지지 않는다
# 실패해야: main 에 합쳐졌다
cd ~/website
git merge feature/new-title || git merge --abort
