# 설명: git rm --cached 만 하고 커밋하지 않았다
# 실패해야: 마지막 커밋에
# 실패해야: git status 가 깨끗하다
cd ~/blog
git rm -r -q --cached .env logs node_modules .DS_Store
