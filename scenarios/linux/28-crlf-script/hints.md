`cd ~/deploy && file *.sh` 를 실행해 보세요. "with CRLF line terminators" 라고 나오는 파일이 있죠? `cat -A deploy.sh | head -3` 으로 보면 줄 끝마다 `^M$` 가 보여요.
---
Windows 는 줄바꿈을 `\r\n`(CRLF), 리눅스는 `\n`(LF)으로 해요. 그래서 첫 줄 `#!/usr/bin/env bash` 가 리눅스에선 `bash\r` 을 찾게 돼요.
---
`sed -i 's/\r$//' deploy.sh` 로 고치고 다시 실행해 보세요. 또 다른 에러(`$'\r': command not found`)가 나면, deploy.sh 가 부르는 **다른 스크립트**도 같은 문제예요.
---
한 번에: `sed -i 's/\r$//' ~/deploy/*.sh ~/deploy/lib/*.sh` → `file ~/deploy/*.sh ~/deploy/lib/*.sh` 로 확인 → `./deploy.sh`
