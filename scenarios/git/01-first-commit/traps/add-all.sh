# 설명: git add . 로 다 올리면 scratch.tmp 까지 커밋된다
# 실패해야: scratch.tmp 는 커밋되지 않았다
cd ~/my-notes && git init -q && git add . && git commit -qm "공부 노트 시작"
