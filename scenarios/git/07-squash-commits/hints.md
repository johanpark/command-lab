`cd ~/todo-app && git log --oneline main..` 으로 합칠 커밋 4개를 확인하세요. 지금 브랜치가 `feature/login` 인지도 `git status` 로!
---
방법 1 (간단): `git reset --soft main` 을 하면 커밋 4개가 사라지고 **변경 내용은 스테이징된 채로** 남아요. 그대로 `git commit -m "로그인 기능 추가"`
---
방법 2 (정석): `git rebase -i main` → 편집기에서 첫 줄은 `pick` 그대로, 나머지 세 줄의 `pick` 을 `squash` (또는 `s`) 로 바꾸고 저장. 이어서 메시지 편집 화면이 나오면 내용을 지우고 `로그인 기능 추가` 만 남기고 저장.
---
확인: `git log --oneline main..` 이 한 줄이고, `git diff ORIG_HEAD` 가 아무것도 출력하지 않으면(내용이 같으면) 성공!
