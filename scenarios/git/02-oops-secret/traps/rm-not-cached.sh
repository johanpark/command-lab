# 설명: --cached 없이 git rm 하면 내 컴퓨터의 .env 파일까지 지워진다
# 실패해야: 내 컴퓨터의 .env
cd ~/shop-api
git rm -q .env
echo ".env" >> .gitignore
git add .gitignore
git commit -q --amend --no-edit
