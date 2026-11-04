# 설명: revert 대신 손으로 고쳐 새 커밋을 만든다
# 실패해야: git revert 로 되돌렸다
cd ~/calculator
bug=$(git blame --porcelain -L '/^add()/,+1' calc.sh | head -n 1 | cut -c1-12)
echo "$bug" > ~/answer.txt
sed -i 's/^add() {.*/add() { echo $(( $1 + $2 )); }/' calc.sh
git commit -qam "add 고침"
