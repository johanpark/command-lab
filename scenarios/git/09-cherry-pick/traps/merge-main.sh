# 설명: main 을 통째로 머지하면 개발 중인 기능까지 release 에 들어간다
# 실패해야: 개발 중인 기능
# 실패해야: 커밋이 딱 하나
cd ~/shop
git switch -q release/1.0
git merge -q --no-edit main
