# push 가 거절됐어요

`~/team-app` 은 팀 원격 저장소(`origin`)를 clone 한 것입니다. 오늘 커밋을 하나 만들고 올리려는데...

```
$ git push
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to '/srv/git/team-app.git'
hint: Updates were rejected because the remote contains work that you do not have locally.
```

그사이 동료가 먼저 push 했대요.

## 목표
1. 내 커밋을 원격 `main` 에 올리세요.
2. **동료의 커밋을 지우면 안 됩니다.** (`git push --force` 금지!)
3. 팀 규칙: 기록은 **한 줄로**. 머지 커밋(`Merge branch ...`)을 만들지 마세요.
4. 마지막엔 내 `main` 과 원격 `main` 이 같아야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `git log --oneline --graph --all` | 내 기록과 원격 기록(`origin/main`) 비교 |
| `git fetch` | 원격 기록만 가져오기 (내 파일은 안 바뀜) |
| `git pull --rebase` | 원격 기록을 가져와서, **내 커밋을 그 위로 옮기기** |
| `git push` | 올리기 |
| `git status` | 앞서 있는지(ahead) 뒤처졌는지(behind) |
