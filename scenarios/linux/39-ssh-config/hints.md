먼저 `ssh -G bastion` 을 쳐 보세요. `Bad owner or permissions` 가 나오면 설정 파일 권한부터 고쳐야 해요. `ls -l ~/.ssh/config` 에서 다른 사용자에게 `w` 가 있으면 ssh 가 파일을 아예 거부해요: `chmod 600 ~/.ssh/config`

그다음 `~/servers.txt` 를 보고 `Host web`, `Host db` 블록을 하나씩 만들면 돼요. 확인은 `ssh -G web | grep -E '^(hostname|user|port|identityfile) '`
---
`user` 가 이상하게 `admin` 으로 나오나요? ssh 는 설정 파일을 **위에서부터** 읽으면서, 항목마다 **처음 정해진 값을 끝까지 써요.** 맨 위의 `Host *` (모든 서버) 블록이 `User admin` 을 먼저 정해 버린 거예요.
---
그래서 구체적인 `Host web`, `Host db` 블록은 **`Host *` 보다 위에** 있어야 해요. `Host *` 블록은 지우지 말고 **맨 아래**로 옮기거나, 새 블록을 파일 맨 위에 넣으세요.
---
권한을 고쳤는데도 거부된다면 `~/.ssh` 폴더도 확인하세요 (`chmod 700 ~/.ssh`). 마지막으로 `ssh -G web`, `ssh -G db`, `ssh -G bastion` 세 개 모두 `user` 와 `serveraliveinterval 60` 이 원하는 대로 나오는지 확인!