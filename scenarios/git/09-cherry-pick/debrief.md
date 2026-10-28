# 해설

```bash
cd ~/shop
git log --oneline release/1.0..main     # main 에만 있는 4개
git show a1b2c3d                        # 보안: 로그인 시도 횟수 제한
git switch release/1.0
git cherry-pick a1b2c3d
git log --oneline -2
```

## merge vs cherry-pick
| | `git merge main` | `git cherry-pick 커밋` |
|---|---|---|
| 가져오는 것 | main 의 **모든** 커밋 | 고른 커밋 **하나의 변경** |
| 이번 상황 | 개발 중인 기능까지 운영에 ❌ | 보안 수정만 ✅ |

## 실무 팁
- `git cherry-pick -x 커밋` 을 쓰면 메시지에 `(cherry picked from commit ...)` 가 붙어서 나중에 출처를 추적하기 쉬워요.
- 충돌이 나면 고치고 `git add` → `git cherry-pick --continue`. 그만두려면 `git cherry-pick --abort`.
- 여러 개: `git cherry-pick A B C` 또는 범위 `git cherry-pick A^..C`
- 핫픽스를 **릴리스 브랜치에서 먼저** 만들고 main 으로 cherry-pick 하는 팀도 있어요. 방향은 달라도 도구는 같아요.
