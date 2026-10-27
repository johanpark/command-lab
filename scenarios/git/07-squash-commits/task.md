# 지저분한 커밋 정리하기

`~/todo-app` 의 `feature/login` 브랜치에서 로그인 기능을 다 만들었습니다. 그런데 커밋 기록이...

```
$ git log --oneline main..feature/login
e4f5a6b 진짜 마지막 wip
c3d4e5f 오타 수정
b2c3d4e wip
a1b2c3d 로그인 폼 추가
```

리뷰어가 보기 좋게, PR 을 올리기 전에 정리하려고 합니다. (아직 push 하지 않은 브랜치예요)

## 목표
1. `feature/login` 브랜치에서 `main` 이후의 커밋 4개를 **커밋 하나로** 합치세요.
2. 합친 커밋의 메시지는 **`로그인 기능 추가`**
3. 최종 **파일 내용은 지금과 똑같아야** 합니다. (기록만 정리)
4. `main` 브랜치는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `git log --oneline --graph --all` | 브랜치 모양 보기 |
| `git rebase -i main` | main 이후 커밋들을 편집기에서 정리 (`pick` → `squash`) |
| `git reset --soft main` | 커밋만 취소하고 변경 내용은 그대로 남기기 |
| `git commit --amend -m "메시지"` | 마지막 커밋 메시지 바꾸기 |

> 💡 편집기는 nano 예요. 저장 `Ctrl+O` → Enter, 나가기 `Ctrl+X`. 꼬이면 `git rebase --abort` 로 처음 상태로 돌아갈 수 있어요.
