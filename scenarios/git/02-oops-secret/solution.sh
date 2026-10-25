cd ~/shop-api
git rm -q --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -q --amend --no-edit
