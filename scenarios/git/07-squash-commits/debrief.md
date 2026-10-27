# 해설

## 방법 1: reset --soft (가장 간단)
```bash
cd ~/todo-app
git reset --soft main            # 커밋 4개 취소, 변경은 스테이징에 그대로
git commit -m "로그인 기능 추가"
```

## 방법 2: rebase -i (정석, 일부만 합칠 때도 가능)
```bash
git rebase -i main
```
편집기에서:
```
pick   a1b2c3d 로그인 폼 추가
squash b2c3d4e wip
squash c3d4e5f 오타 수정
squash e4f5a6b 진짜 마지막 wip
```
저장하면 메시지 편집 화면이 나와요. 네 개의 메시지를 지우고 `로그인 기능 추가` 만 남기면 끝.

## rebase -i 에서 쓸 수 있는 것
| 명령 | 뜻 |
|---|---|
| `pick` | 그대로 둠 |
| `squash` (`s`) | 앞 커밋에 합치고 메시지도 합침 |
| `fixup` (`f`) | 앞 커밋에 합치고 이 메시지는 버림 |
| `reword` (`r`) | 메시지만 수정 |
| `drop` (`d`) | 커밋 삭제 |
| 줄 순서 바꾸기 | 커밋 순서 변경 |

## 꼭 기억할 것
- 기록을 고쳐 쓰는(rebase, reset, amend) 작업은 **push 하기 전**에만. 이미 공유했다면 `git push --force-with-lease` 가 필요하고, 팀원과 미리 이야기해야 해요.
- 자주 쓰는 습관: 작업 중엔 마음껏 wip 커밋 → PR 전에 `git commit --fixup` + `git rebase -i --autosquash` 로 정리.
