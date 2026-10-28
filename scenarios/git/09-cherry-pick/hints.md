`cd ~/shop && git log --oneline release/1.0..main` 으로 main 에만 있는 커밋을 보세요. 메시지에 "보안" 이 들어간 커밋이 있어요.
---
`git show <해시>` 로 정말 보안 수정만 들어 있는지 확인하세요.
---
`git switch release/1.0` → `git cherry-pick <해시>`
---
확인: `git log --oneline -3` (맨 위에 보안 수정), `ls` 로 main 의 새 기능 파일(coupon.js 등)이 **없는지** 확인!
