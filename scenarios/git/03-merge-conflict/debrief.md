# 해설

```bash
cd ~/website
git merge feature/new-title     # CONFLICT (content): Merge conflict in index.html
git status                      # both modified: index.html
nano index.html                 # 아래처럼 정리
git add index.html
git commit                      # 머지 커밋 메시지가 자동으로 채워짐
git log --oneline --graph
```

충돌 부분:
```
<<<<<<< HEAD
    <h1>명령어 연습장 - 매일 조금씩</h1>
=======
    <h1>커맨드 연습장</h1>
>>>>>>> feature/new-title
```
정리 후:
```
    <h1>커맨드 연습장 - 매일 조금씩</h1>
```

## 기억할 것
- 충돌은 에러가 아니라 "**둘 다 같은 곳을 고쳤으니 사람이 정해 달라**"는 요청이에요.
- Git 은 겹치지 않는 변경(footer, nav)은 알아서 합쳐 줍니다. 사람이 고칠 곳은 표시된 부분뿐이에요.
- 꼬였다 싶으면 언제든 `git merge --abort` 로 머지 전으로 돌아갈 수 있어요.
- `git diff` 는 충돌 중에 양쪽 차이를 보여주고, `git log --oneline --graph --all` 은 브랜치가 갈라지고 합쳐진 모양을 보여줍니다.
