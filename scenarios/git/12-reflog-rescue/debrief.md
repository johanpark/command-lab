# 해설

```bash
cd ~/app
git reflog                                   # 어디 있었는지 확인
git reset --hard 'main@{1}'                  # main 이 reset 직전 위치로 (또는 ORIG_HEAD)
git branch feature/payment <reflog 의 해시>  # 브랜치 다시 만들기
git log --oneline --all --graph              # 확인
```

## reflog = Git 의 블랙박스
`git reflog` 는 **내 컴퓨터에서** HEAD 와 브랜치가 움직인 기록이에요.
```
a1b2c3d HEAD@{0}: reset: moving to HEAD~3          ← 사고
9f8e7d6 HEAD@{1}: checkout: moving from feature/payment to main
3f2a1c9 HEAD@{2}: commit: 결제 실패 재시도           ← feature/payment 의 마지막
...
```
- `HEAD@{n}` : HEAD 가 n 번 전에 있던 곳
- `main@{1}` : main 브랜치가 한 번 전에 가리키던 곳
- `ORIG_HEAD` : reset, merge, rebase 직전 위치 (한 단계만 기억)

## 언제까지 살릴 수 있나?
브랜치에서 떨어진 커밋도 reflog 에 남아 있는 동안은 지워지지 않아요. 기본 **90일**(도달 불가 커밋은 30일) 뒤 `git gc` 가 정리해요. 단, **커밋하지 않은 변경**은 reflog 에도 없어요. `reset --hard` 전에는 `git stash` 를 습관처럼!

## 비슷한 사고들
| 사고 | 복구 |
|---|---|
| rebase 를 망쳤다 | `git reset --hard ORIG_HEAD` 또는 reflog 에서 rebase 전 위치 |
| amend 로 커밋을 덮었다 | `git reflog` → 이전 커밋 해시 |
| 브랜치를 지웠다 | `git branch 이름 해시` |
| push --force 로 원격을 덮었다 | 다른 사람의 로컬 reflog 나 원격 서비스의 기록 |
