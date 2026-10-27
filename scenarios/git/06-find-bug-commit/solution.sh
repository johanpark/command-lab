cd ~/calculator
bug=$(git blame --porcelain -L '/^add()/,+1' calc.sh | head -n 1 | cut -c1-12)
echo "$bug" > ~/answer.txt
GIT_EDITOR=true git revert --no-edit "$bug" >/dev/null
