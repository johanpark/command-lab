# 설명: 버그 커밋 이전으로 reset --hard 하면 그 뒤의 pow 까지 사라진다
# 실패해야: 기존 커밋 기록이 그대로
# 실패해야: pow(거듭제곱)는 살아 있다
cd ~/calculator
bug=$(git blame --porcelain -L '/^add()/,+1' calc.sh | head -n 1 | cut -c1-12)
echo "$bug" > ~/answer.txt
git reset -q --hard "$bug^"
