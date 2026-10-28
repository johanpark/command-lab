`git log` 에는 사라진 커밋이 안 보여요. 하지만 Git 은 **커밋을 바로 지우지 않아요.** `git reflog` 를 쳐 보세요. HEAD 가 거쳐 간 모든 위치가 최신순으로 나와요.
---
맨 위에 `reset: moving to HEAD~3` 이 보일 거예요. 그 **바로 아래 줄**이 reset 직전의 위치예요. `git log --oneline 그해시` 로 커밋 3개가 다 있는지 확인하세요. (`ORIG_HEAD` 도 reset 직전 위치를 기억해요)
---
main 복구: `git reset --hard 그해시` (또는 `git reset --hard 'main@{1}'`)
---
브랜치: reflog 에서 `checkout: moving from feature/payment to main` 줄을 찾으세요. 그 **바로 아래 줄**이 feature/payment 를 떠나기 직전 커밋이에요. `git branch feature/payment 그해시`. 또는 `Deleted branch ... (was 해시)` 메시지의 해시를 써도 돼요.
