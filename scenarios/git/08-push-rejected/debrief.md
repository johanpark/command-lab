# 해설

```bash
cd ~/team-app
git push                         # rejected (fetch first)
git fetch
git log --oneline --graph --all  # 내 커밋과 origin/main 이 갈라져 있음
git pull --rebase                # 내 커밋을 동료 커밋 위로 옮김
git log --oneline --graph        # 한 줄
git push
```

## 무슨 일이 일어났나
```
처음:      A ── B (동료, origin/main)
            └── C (나, main)

rebase 후: A ── B ── C'          ← 내 커밋을 B 뒤로 "다시 적용"
merge 라면: A ── B ──── M        ← 합치는 커밋 M 이 생김
             └── C ──┘
```

## 절대 하면 안 되는 것
`git push --force` 는 **원격 기록을 내 것으로 덮어써서** 동료의 커밋 B 를 지워 버려요. 꼭 필요할 땐 `--force-with-lease` (내가 아는 원격 상태와 같을 때만 덮어씀).

## 매번 --rebase 를 치기 귀찮다면
```bash
git config --global pull.rebase true
```

## 충돌이 나면?
같은 줄을 동료와 내가 고쳤다면 rebase 도중 멈춰요. 파일을 고치고 `git add 파일` → `git rebase --continue`. 꼬이면 `git rebase --abort` 로 원래대로.
