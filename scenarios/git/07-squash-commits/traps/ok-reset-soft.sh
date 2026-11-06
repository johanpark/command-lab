# 설명: reset --soft main 후 다시 커밋해도 맞는 풀이다
# 통과해야
cd ~/todo-app
git reset -q --soft main
git commit -qm "로그인 기능 추가"
