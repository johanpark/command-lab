`git ls-files` 를 쳐 보세요. `.env`, `logs/app.log`, `node_modules/...` 가 보이죠? `.gitignore` 는 **아직 추적하지 않는 파일**에만 적용돼요. 이미 커밋된 파일은 계속 추적돼요.
---
추적을 끊으려면 저장소(인덱스)에서 빼야 해요. 그냥 `git rm` 은 **실제 파일도 지워요!** `--cached` 를 붙이면 저장소에서만 빠져요.
---
`git rm -r --cached .env logs node_modules .DS_Store` → `git status` 로 `deleted:` 로 보이는지 확인 (저장소에서 지운다는 뜻) → `ls -a` 로 실제 파일이 남아 있는지 확인
---
`git commit -m "추적하면 안 되는 파일 제거"`. 끝나면 `git status` 가 깨끗하고, 로그를 바꿔도 더 이상 잡히지 않아요.
