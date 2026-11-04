# 설명: 충돌 표시만 지우고 두 제목을 다 남기면 h1 이 두 개가 된다
# 실패해야: 제목(h1)이 하나뿐
cd ~/website
git merge feature/new-title || true
sed -i '/^\(<<<<<<<\|=======\|>>>>>>>\)/d' index.html
git add index.html
GIT_EDITOR=true git commit -q --no-edit
