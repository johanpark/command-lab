cd ~/website
git merge feature/new-title || true
sed -i -e '/^<<<<<<< /,/^>>>>>>> /c\    <h1>커맨드 연습장 - 매일 조금씩</h1>' index.html
git add index.html
GIT_EDITOR=true git commit -q --no-edit
