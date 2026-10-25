`cd ~` 로 홈에서 시작하세요. `mkdir blog` 로 폴더를 만들고, `mkdir blog/posts` 처럼 안쪽 폴더도 만들 수 있어요.
---
폴더 여러 개를 한 번에: `mkdir -p ~/blog/posts ~/blog/images ~/blog/drafts`
---
복사는 `cp ~/templates/README.md ~/blog/`, 빈 파일은 `touch ~/blog/drafts/ideas.md`
---
이동하면서 이름 바꾸기: `mv ~/draft.md ~/blog/posts/2026-hello.md`. 마지막으로 `tree ~/blog` 로 구조를 확인해 보세요.
