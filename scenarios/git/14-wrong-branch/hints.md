`git log --oneline --graph --all` 로 보면 `main` 이 `origin/main` 보다 3칸 앞서 있어요. 커밋은 그대로 두고 **이름표(브랜치)만** 옮기면 돼요.
---
흔한 실수: `git reset --hard origin/main` 부터 하면 3개 커밋이 main 에서 떨어져 나가고, **커밋 안 한 coupon.js 수정은 영영 사라져요.** 순서가 중요해요.
---
1단계: 지금 위치에 새 이름표를 붙이고 그리로 이동: `git switch -c feature/coupon`. 커밋 안 한 수정도 그대로 따라와요.
---
2단계: 이제 main 이 아닌 곳에 있으니 main 이름표만 뒤로 옮겨요: `git branch -f main origin/main`. 마지막으로 `git status` (feature/coupon, coupon.js modified) 와 `git log --oneline --graph --all` 로 확인!
