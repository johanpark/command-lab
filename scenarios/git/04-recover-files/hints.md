`cd ~/recipes && git status` 부터. modified 와 deleted 가 보일 거예요. Git 이 친절하게 `git restore <file>` 을 쓰라고 알려줍니다.
---
`git restore kimchi.md bulgogi.md` 로 1, 2번 해결. ⚠️ `git restore` 로 버린 변경은 되돌릴 수 없으니, 정말 버려도 되는지 `git diff` 로 먼저 확인하는 습관!
---
`git log --oneline --diff-filter=D --name-only` 로 bibimbap.md 를 지운 커밋을 찾으세요. 지운 커밋 **안**에는 파일이 없으니, 그 **바로 전** 커밋(`커밋^`)에서 꺼내야 해요.
---
`git restore --source=<지운커밋>^ bibimbap.md` (또는 `git checkout <지운커밋>^ -- bibimbap.md`) → `git add bibimbap.md` → `git commit -m "비빔밥 레시피 복구"`
