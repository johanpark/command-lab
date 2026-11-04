# 설명: pull --rebase 없이 pull 하면 머지 커밋이 생긴다
# 실패해야: 원격 main 기록이 한 줄이다
cd ~/team-app
git -c pull.rebase=false pull -q --no-edit
git push -q
