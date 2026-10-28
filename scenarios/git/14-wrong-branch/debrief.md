# 해설

```bash
cd ~/shop
git switch -c feature/coupon       # 지금 위치(커밋 3개 + 수정 중인 파일)를 새 브랜치로
git branch -f main origin/main     # main 이름표만 원격 위치로
git log --oneline --graph --all
```

## 브랜치는 "이름표"
Git 의 브랜치는 커밋 하나를 가리키는 **이름표**일 뿐이에요. 커밋을 옮기는 게 아니라 이름표를 다시 붙이는 거라서 아주 빠르고 안전해요.
```
전:  origin/main ── A ── B ── C   ← main (HEAD)
후:  origin/main ── A ── B ── C   ← feature/coupon (HEAD)
         ↑ main
```

## 다른 방법들
| 방법 | 메모 |
|---|---|
| `git branch feature/coupon` → `git reset --keep origin/main` → `git switch feature/coupon` | `--keep` 은 수정 중인 파일이 있으면 위험할 때 멈춰 줘요 |
| `git stash` → `git branch feature/coupon` → `git reset --hard origin/main` → `git switch feature/coupon` → `git stash pop` | 수정 사항을 잠깐 치워 두고 |
| 이미 push 까지 했다면 | main 을 되돌리려면 force push 가 필요해요. 팀과 먼저 상의하고, 보통은 그냥 두고 revert 하거나 PR 로 정리해요 |

## 이런 일을 막으려면
- 작업 시작 전 `git switch -c feature/...` 를 습관으로
- 셸 프롬프트에 현재 브랜치 표시 (`__git_ps1`, starship 등)
- GitHub 의 **브랜치 보호 규칙**으로 main 직접 push 금지
