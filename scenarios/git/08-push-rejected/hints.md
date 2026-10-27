`cd ~/team-app && git fetch` 후 `git status` 를 보세요. "have diverged" — 내 쪽에도, 원격 쪽에도 서로 모르는 커밋이 하나씩 있다는 뜻이에요. `git log --oneline --graph --all` 로 모양을 보세요.
---
그냥 `git pull` 을 하면 "Need to specify how to reconcile divergent branches" 라며 방법을 고르라고 해요. 머지 커밋 없이 한 줄로 만들려면 **rebase** 를 고르면 돼요.
---
`git pull --rebase` → 내 커밋이 동료 커밋 **뒤로** 옮겨져요. `git log --oneline --graph` 로 한 줄인지 확인하세요.
---
그다음 `git push`. 이번엔 성공! `git status` 에 "up to date with 'origin/main'" 이 보이면 끝이에요.
