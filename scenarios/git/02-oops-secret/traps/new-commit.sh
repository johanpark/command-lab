# 설명: amend 대신 새 커밋으로 지우면 이전 커밋에 .env 가 그대로 남는다
# 실패해야: 어떤 커밋에도 .env 가 없다
cd ~/shop-api
git rm -q --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -qm ".env 제거"
