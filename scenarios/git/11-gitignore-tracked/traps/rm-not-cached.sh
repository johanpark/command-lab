# 설명: --cached 없이 git rm 이 거부되자 -f 로 밀어붙이면 실제 파일까지 지워진다
# 실패해야: 실제 파일은 지워지지 않았다
cd ~/blog
git rm -r -q -f .env logs node_modules .DS_Store
git commit -qm "추적하면 안 되는 파일 제거"
