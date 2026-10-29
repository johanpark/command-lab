`git show --stat HEAD` 로 보면 마지막 커밋에 `login.html` 만 있어요. `login.css` 는 아직 Git 이 추적하지 않는 파일이에요.
---
먼저 빠뜨린 파일을 스테이징: `git add login.css`. 여기서 `git commit -m ...` 을 하면 커밋이 **하나 더** 생겨요. 대신 `--amend` 를 쓰세요.
---
`git commit --amend -m "로그인 페이지 추가"` 한 번으로 메시지도 고치고 login.css 도 합쳐져요. `git log --oneline -3` 과 `git show --stat HEAD` 로 확인!
---
마지막으로 `git push`. 아직 push 하기 전에 고쳤으니 그냥 push 가 돼요. (이미 push 한 커밋을 amend 하면 force push 가 필요해져요 → 해설 참고)
