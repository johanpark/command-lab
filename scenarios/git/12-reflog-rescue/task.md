# reset --hard 로 날린 커밋 되살리기 (reflog)

퇴근 직전, 저장소 `~/app` 을 "정리"한다고 이렇게 쳤어요.

```
$ git branch -D feature/payment
Deleted branch feature/payment (was 3f2a1c9).
$ git reset --hard HEAD~3
HEAD is now at 8d0e7b2 로그인 화면
```

그런데 알고 보니 **main 의 최근 커밋 3개는 아직 필요한 작업**이었고, `feature/payment` 브랜치도 아직 머지 전이었어요. 😱

## 목표
1. `main` 을 `reset` 하기 **직전** 상태로 되돌리세요.
2. 삭제한 `feature/payment` 브랜치를 **삭제 직전의 커밋**으로 다시 만드세요.
3. 끝나면 `main` 브랜치에 있고, `git status` 가 깨끗해야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `git reflog` | HEAD 가 움직인 **모든 기록** (커밋, reset, checkout ...) |
| `git reflog show main` | main 브랜치가 움직인 기록 |
| `git show 해시` / `git log --oneline 해시` | 그 커밋이 맞는지 확인 |
| `git reset --hard 해시` | 지금 브랜치를 그 커밋으로 |
| `git branch 이름 해시` | 그 커밋에 브랜치 만들기 |
| `HEAD@{2}` | reflog 의 두 단계 전 위치 |
