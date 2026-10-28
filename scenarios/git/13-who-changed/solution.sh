cd ~/api
git log -S 'TIMEOUT_MS: 300,' --format=%h | tail -n 1 > ~/answer.txt
sed -i 's/TIMEOUT_MS: 300,/TIMEOUT_MS: 3000,/' config.js
git commit -qam "타임아웃 3000ms 로 되돌림"
