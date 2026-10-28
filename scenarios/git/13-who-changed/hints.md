`cd ~/api && git blame config.js` 를 해 보세요. 모든 줄이 같은 커밋을 가리키죠? `git show 그해시` 로 보면 **들여쓰기만 바꾼** 포맷 정리 커밋이에요. blame 은 "마지막으로 그 줄을 건드린 커밋"을 보여줘서, 공백만 바꿔도 그 사람이 범인처럼 보여요.
---
`git blame -w config.js` 는 공백 변경을 무시해요. 이제 `TIMEOUT_MS` 줄이 진짜로 값을 바꾼 커밋을 가리킬 거예요.
---
다른 방법: `git log -S 'TIMEOUT_MS: 300,' --oneline`. ⚠️ 쉼표 없이 `-S 'TIMEOUT_MS: 300'` 으로 찾으면 `3000` 안에도 `300` 이 들어 있어서 **처음 만든 커밋만** 나와요. `-S` 는 그 문자열의 **개수가 바뀐** 커밋을 찾거든요.
---
고치기: `sed -i 's/TIMEOUT_MS: 300,/TIMEOUT_MS: 3000,/' config.js` → `git diff` 로 확인 → `git commit -am "타임아웃 3000ms 로 되돌림"`. (`git revert` 는 그 커밋의 다른 변경까지 되돌리니 내용을 먼저 확인하세요)
