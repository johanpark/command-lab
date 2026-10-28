# main 에 커밋해 버렸어요 (브랜치로 옮기기)

쿠폰 기능을 만들기 시작했는데, 신나서 코딩하다 보니 **브랜치를 안 만들고 `main` 에 바로 커밋**해 버렸어요. 커밋이 3개나 쌓였고, 아직 커밋 안 한 수정도 하나 있어요.

```
$ git status
On branch main
Your branch is ahead of 'origin/main' by 3 commits.
Changes not staged for commit:
        modified:   coupon.js
```

팀 규칙상 `main` 에는 직접 커밋하면 안 돼요. 다행히 아직 push 는 안 했어요.

## 목표 (`~/shop` 저장소)
1. 쿠폰 작업 커밋 3개를 **`feature/coupon`** 브랜치로 옮기세요.
2. 아직 커밋 안 한 `coupon.js` 수정도 **잃어버리면 안 돼요.** (`feature/coupon` 에서 계속 작업할 수 있게)
3. `main` 은 원격과 같은 위치(**`origin/main`**)로 되돌리세요.
4. 끝나면 **`feature/coupon` 브랜치에서** 작업 중인 상태여야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `git log --oneline --graph --all` | 브랜치와 커밋 위치 한눈에 |
| `git switch -c 새브랜치` | **지금 위치에서** 새 브랜치를 만들고 이동 (작업 중인 수정도 따라옴) |
| `git branch -f main origin/main` | main 이 가리키는 곳을 옮기기 (지금 main 이 아닐 때) |
| `git reset --hard 위치` | 지금 브랜치를 옮기고 **수정 사항도 버림** ⚠️ |
| `git stash` / `git stash pop` | 수정 사항 잠깐 치워 두기 / 되돌리기 |
