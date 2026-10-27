`cat ~/deploy/cron.log` 와 스크립트(`cat ~/deploy/nightly.sh`)를 비교해 보세요. `./config/deploy.env` 같은 **상대 경로**는 "지금 있는 폴더" 기준이에요. cron 은 홈 폴더(또는 /)에서 실행해요.
---
스크립트가 자기 폴더로 먼저 이동하게 하면 돼요. `set -e` 아래에 `cd "$(dirname "$0")"` 를 추가하세요. 그다음 목표의 `env -i ...` 명령으로 다시 시험!
---
이번엔 `notify: command not found` 가 나올 거예요. `notify` 는 `~/.local/bin` 에 있는데, 이 폴더는 **로그인한 셸에서만** PATH 에 들어가요. cron 의 PATH 는 `/usr/bin:/bin` 뿐이에요.
---
스크립트 안에서 전체 경로(`"$HOME/.local/bin/notify"`)로 부르거나, 위쪽에 `export PATH="$HOME/.local/bin:$PATH"` 를 넣으세요.
