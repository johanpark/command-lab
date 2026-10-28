먼저 cron 처럼 실행해 보세요: `cd ~ && env -i HOME=$HOME PATH=/usr/bin:/bin sh -c 'python3 /home/learner/jobs/cleanup.py'`. 두 스크립트 모두 에러가 날 거예요. 에러 메시지를 잘 읽어 보세요.
---
cleanup.py: `FileNotFoundError: 'config.json'`. 스크립트가 **지금 폴더 기준**(상대 경로)으로 `config.json` 을 찾아요. 터미널에선 `cd ~/jobs` 하고 실행해서 됐던 거예요. cron 은 **홈 폴더**에서 실행해요. 해결: 명령 앞에 `cd /home/learner/jobs && ` 를 붙이거나, 스크립트가 자기 위치를 기준으로 찾게 고치기 (`Path(__file__).parent / "config.json"`).
---
daily_report.js: `REPORT_DIR 가 설정되지 않았습니다`. `REPORT_DIR` 은 `~/.bashrc` 에서 export 돼요. 그런데 cron 은 **.bashrc 를 읽지 않아요.** 해결: crontab 맨 위에 `REPORT_DIR=/home/learner/daily-reports` 한 줄을 넣거나, 명령 앞에 `REPORT_DIR=/home/learner/daily-reports node ...` 처럼 붙이기. ⚠️ crontab 의 변수 줄에서는 `$HOME` 같은 변수가 **풀리지 않으니** 전체 경로를 쓰세요.
---
완성 예:
```
REPORT_DIR=/home/learner/daily-reports
*/30 * * * * cd /home/learner/jobs && /usr/bin/python3 cleanup.py >> /home/learner/jobs/logs/cleanup.log 2>&1
30 7 * * * /usr/bin/node /home/learner/jobs/daily_report.js >> /home/learner/jobs/logs/report.log 2>&1
```
`~/jobs/logs` 폴더가 없으면 로그를 못 남겨요. `mkdir -p ~/jobs/logs` 도 잊지 마세요!
