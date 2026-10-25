`cd ~/shop-api && git log --stat` 으로 어느 커밋에 `.env` 가 들어갔는지 확인하세요. 맨 위(가장 최근) 커밋이죠?
---
`git rm --cached .env` 를 하면 파일은 그대로 두고 Git 에서만 "삭제"로 표시돼요. `ls -a` 로 파일이 남아 있는지 확인해 보세요.
---
그냥 새 커밋을 하면 `.env` 는 **이전 커밋에 여전히 남아요**. 마지막 커밋 자체를 고쳐야 합니다: `git commit --amend`
---
`echo .env >> .gitignore` → `git add .gitignore` → `git rm --cached .env` → `git commit --amend --no-edit`. 마지막에 `git log --stat` 과 `git status` 로 확인!
