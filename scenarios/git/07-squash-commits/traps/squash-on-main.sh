# 설명: reset --soft 를 main 보다 한 칸 더 가면 커밋이 main 바로 위가 아니라 main 의 마지막 커밋을 품고 갈라진다
# 실패해야: main 바로 위에
cd ~/todo-app
git reset -q --soft main~1
git commit -qm "로그인 기능 추가"
