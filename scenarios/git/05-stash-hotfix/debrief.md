# 해설

```bash
cd ~/shop
git status                    # feature/coupon, modified: cart.js
git stash                     # 작업 중인 변경을 보관함으로
git switch main
nano price.js                 # TAX_RATE = 0.1
git commit -am "세율 버그 수정"
git switch feature/coupon
git stash pop                 # 하던 작업 복귀
git status                    # modified: cart.js
```

## 왜 그냥 `git switch main` 이 안 됐을까?
`cart.js` 는 `feature/coupon` 과 `main` 에서 내용이 달라요. 이 상태로 브랜치를 옮기면 작업 중인 변경이 덮어써질 수 있어서 Git 이 막아 줍니다. (두 브랜치에서 내용이 같은 파일이라면 변경을 들고 그대로 이동해요. 그러다 엉뚱한 브랜치에 커밋하는 실수가 흔하니, 이동 전엔 항상 `git status`!)

## stash 더 알아보기
```bash
git stash push -m "쿠폰 작업 중"   # 이름 붙여서 보관
git stash list                      # stash@{0}: On feature/coupon: 쿠폰 작업 중
git stash show -p stash@{0}         # 내용 보기
git stash apply                     # 꺼내되 보관함에서 지우지 않음
git stash drop                      # 보관함에서 지우기
git stash -u                        # 새로 만든(untracked) 파일까지 보관
```

## 다른 방법
- **WIP 커밋**: `git commit -am "WIP"` 후 나중에 `git reset --soft HEAD~1` 로 풀기
- **worktree**: `git worktree add ../shop-hotfix main` 으로 폴더를 하나 더 만들어 동시에 작업
