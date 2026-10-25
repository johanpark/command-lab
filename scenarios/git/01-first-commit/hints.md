`cd ~/my-notes` 후 `git init`. 그다음 `git status` 를 쳐 보세요. Git이 지금 어떤 파일을 보고 있는지 알려줍니다.
---
`git add notes.md todo.md` 로 두 파일만 담으세요. `git add .` 은 모든 파일을 담아서 scratch.tmp 까지 들어가요.
---
담은 뒤 `git status` 를 다시 보면 "Changes to be committed" 아래에 두 파일이 보일 거예요. 이제 `git commit -m "첫 노트"`
---
`git log --oneline` 으로 커밋이 생겼는지 확인! 혹시 scratch.tmp 까지 담았다면 `git restore --staged scratch.tmp` 로 빼면 돼요.
