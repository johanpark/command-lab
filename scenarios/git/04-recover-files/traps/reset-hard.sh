# 설명: 지우기 전 커밋으로 reset --hard 하면 그 뒤 커밋 기록이 사라진다
# 실패해야: 기존 커밋 기록은 그대로
cd ~/recipes
del=$(git log --format=%h --diff-filter=D -n 1 -- bibimbap.md)
git reset -q --hard "$del^"
