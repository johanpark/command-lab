`cd ~/website && git branch` 로 지금 main 에 있는지 확인하고, `git merge feature/new-title` 을 실행하세요.
---
`cat index.html` 을 보면 충돌 부분이 이렇게 표시돼요:
```
<<<<<<< HEAD
(내 쪽 main 의 내용)
=======
(feature/new-title 의 내용)
>>>>>>> feature/new-title
```
---
`nano index.html` 로 열어서 표시 줄 3개(`<<<<<<<`, `=======`, `>>>>>>>`)를 지우고, 두 내용을 합쳐 원하는 한 줄만 남기세요.
---
저장 후 `git add index.html` → `git commit` (메시지는 자동으로 채워져요. nano 가 열리면 그대로 `Ctrl+X`). 끝나면 `git log --oneline --graph` 로 확인!
