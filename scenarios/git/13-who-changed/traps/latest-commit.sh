# 설명: config.js 를 마지막으로 고친 커밋이 범인은 아니다 (값을 바꾼 커밋은 log -S 나 blame 으로)
# 실패해야: 3000 → 300 으로 바꾼 커밋
cd ~/api
git log -1 --format=%h -- config.js > ~/answer.txt
sed -i 's/TIMEOUT_MS: 300,/TIMEOUT_MS: 3000,/' config.js
git commit -qam "타임아웃 3000ms 로 되돌림"
