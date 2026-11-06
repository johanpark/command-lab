# 설명: 비빔밥 레시피를 처음 커밋에서 꺼내면 나중에 추가한 비법이 빠진다
# 실패해야: 지워지기 직전 내용
cd ~/recipes
git restore kimchi.md bulgogi.md
first=$(git log --format=%h --diff-filter=A -n 1 -- bibimbap.md)
git restore --source="$first" bibimbap.md
git add bibimbap.md
git commit -qm "비빔밥 레시피 복구"
