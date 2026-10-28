# 해설

```bash
cd ~/blog
git ls-files                                   # 무엇이 추적 중인지
git rm -r --cached .env logs node_modules .DS_Store
git commit -m "추적하면 안 되는 파일 제거"
git status                                     # 깨끗!
```

한꺼번에 정리하는 방법도 많이 써요:
```bash
git rm -r --cached .        # 전부 추적 해제 (실제 파일은 그대로)
git add .                   # .gitignore 를 적용해서 다시 추가
git commit -m "gitignore 적용"
```

## .gitignore 는 "새 파일" 에만
`.gitignore` 는 `git add` 할 때 **추적하지 않는 파일을 걸러 주는** 규칙이에요. 이미 추적 중인 파일에는 아무 효과가 없어요. 그래서 "처음부터 `.gitignore` 를 만들고 시작하기" 가 정답이에요. (`npx gitignore node`, github/gitignore 템플릿 활용)

## ⚠️ .env 는 아직 기록에 남아 있어요
추적을 끊어도 **이전 커밋에는 `.env` 내용이 그대로** 있어요. `git show HEAD~2:.env` 로 누구나 볼 수 있죠. 비밀번호나 키가 들어 있었다면:
1. **먼저 그 키를 폐기·교체**하세요. (가장 중요)
2. 필요하면 기록에서 지우기: `git filter-repo --path .env --invert-paths` (모든 사람이 다시 clone 해야 함)

Git 환경의 "비밀번호를 커밋해 버렸다" 시나리오도 함께 풀어 보세요.

## 확인 명령어
| 명령어 | 용도 |
|---|---|
| `git check-ignore -v logs/app.log` | 무시되는지, 어느 규칙 때문인지 |
| `git status --ignored` | 무시된 파일까지 보기 |
| `git ls-files -ci --exclude-standard` | 무시 규칙에 걸리는데 **추적 중인** 파일 찾기 |
