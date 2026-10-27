`cd ~/calculator && cat calc.sh` 로 add 함수를 보세요. `+` 가 아니라 `$1 - $2` 로 되어 있죠? 이 줄이 언제 바뀌었는지가 핵심이에요.
---
`git blame calc.sh` 는 줄마다 마지막으로 바꾼 커밋 해시를 맨 앞에 보여줘요. add 줄의 해시를 보세요. 또는 `git log -L '/^add/,+1:calc.sh' --oneline` 으로 add 줄의 변경 이력만 볼 수도 있어요.
---
`git show <해시>` 로 정말 그 커밋이 범인인지 확인! 커밋 메시지는 "코드 스타일 정리"처럼 무해해 보일 수 있어요.
---
`echo <해시> > ~/answer.txt` → `git revert <해시>` (편집기가 열리면 그대로 저장하고 닫기: nano 는 `Ctrl+X`) → `./test.sh`
