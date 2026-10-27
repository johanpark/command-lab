# 해설

```bash
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"                      # 1. 스크립트 폴더로 이동
export PATH="$HOME/.local/bin:$PATH"      # 2. 필요한 PATH 직접 지정
source ./config/deploy.env
...
```

## cron 이 "손으로 실행"과 다른 점
| | 터미널에서 직접 | cron |
|---|---|---|
| 현재 폴더 | 내가 `cd` 한 곳 | 홈 폴더 |
| PATH | `.bashrc`, `.profile` 이 늘려 둔 것 | `/usr/bin:/bin` 정도 |
| 환경 변수 | 로그인 셸의 것 전부 | 거의 없음 |
| 출력 | 화면 | 버려지거나 메일로 (그래서 `>> log 2>&1`) |

## 어디서든 동작하는 스크립트 습관
- 스크립트 첫 부분에서 `cd "$(dirname "$0")"` 또는 `SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)` 로 기준 폴더를 잡기
- 외부 명령은 PATH 를 직접 설정하거나 전체 경로로 부르기
- 배포 전에 `env -i HOME=$HOME PATH=/usr/bin:/bin bash 스크립트` 로 **cron 흉내** 테스트

## 대안
crontab 에서 직접 해결할 수도 있어요.
```
PATH=/home/learner/.local/bin:/usr/bin:/bin
0 3 * * * cd /home/learner/deploy && ./nightly.sh >> cron.log 2>&1
```
다만 스크립트 자체가 튼튼하면 cron, CI, 다른 사람 등 **누가 어디서 실행하든** 안전해요.
