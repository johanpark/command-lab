# 설명: 기록을 고쳐 쓰면(amend) 안 되고 새 커밋으로 고쳐야 한다
# 실패해야: 새 커밋으로 고쳤다
cd ~/api
git log -S 'TIMEOUT_MS: 300,' --format=%h | tail -n 1 > ~/answer.txt
sed -i 's/TIMEOUT_MS: 300,/TIMEOUT_MS: 3000,/' config.js
git commit -q -a --amend --no-edit
