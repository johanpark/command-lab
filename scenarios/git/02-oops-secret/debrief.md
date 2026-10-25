# 해설

```bash
cd ~/shop-api
git log --stat                 # 마지막 커밋에 .env 가 들어간 것 확인
git rm --cached .env           # Git 에서만 빼기 (파일은 남음)
echo ".env" >> .gitignore
git add .gitignore
git commit --amend --no-edit   # 마지막 커밋을 고쳐 쓰기
git log --stat                 # .env 가 사라졌는지 확인
git status                     # 깨끗!
```

## 다른 방법: 커밋을 취소하고 다시 하기
```bash
git reset --soft HEAD~1        # 마지막 커밋만 취소, 변경 내용은 스테이징에 그대로
git rm --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -m "주문 API 추가"
```

## 꼭 기억할 것
- 그냥 "삭제 커밋"을 하나 더 만들면 `.env` 는 **이전 커밋에 영원히 남아 있습니다**. `git checkout HEAD~1 -- .env` 하면 누구나 꺼내 볼 수 있어요.
- `--amend` / `reset` 은 **push 하기 전**에만 안전합니다. 이미 push 했다면 기록을 고치는 것보다 **비밀번호를 즉시 바꾸는 것**이 먼저예요.
- 프로젝트 시작할 때 `.gitignore` 에 `.env` 를 넣어 두는 습관!
