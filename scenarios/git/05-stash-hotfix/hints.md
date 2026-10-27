`cd ~/shop && git status` 로 지금 브랜치와 바뀐 파일을 보세요. 이 상태로 `git switch main` 을 해 보면... Git 이 거부할 거예요. 왜일까요?
---
"Your local changes would be overwritten" = 작업 중인 변경이 브랜치를 옮기면 날아갈 수 있다는 뜻이에요. `git stash` 로 치우면 `git status` 가 깨끗해집니다.
---
`git switch main` → `nano price.js` 에서 `TAX_RATE` 수정 (또는 `sed -i 's/TAX_RATE = 0.01/TAX_RATE = 0.1/' price.js`) → `git commit -am "세율 버그 수정"`
---
`git switch feature/coupon` → `git stash pop`. `git status` 에 cart.js 가 modified 로 보이면 성공! `git stash list` 가 비어 있는지도 확인해 보세요.
