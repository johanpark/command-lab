cd ~/app
git reset -q --hard 'main@{1}'
n=$(git log -g --format='%gd|%gs' HEAD | grep -m1 'moving from feature/payment to main' | sed 's/^HEAD@{\([0-9]*\)}.*/\1/')
git branch feature/payment "HEAD@{$((n + 1))}"
git log --oneline --all --graph
