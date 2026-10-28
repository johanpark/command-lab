# 해설

```
REPORT_DIR=/home/learner/daily-reports
*/30 * * * * cd /home/learner/jobs && /usr/bin/python3 cleanup.py >> /home/learner/jobs/logs/cleanup.log 2>&1
30 7 * * *   /usr/bin/node /home/learner/jobs/daily_report.js >> /home/learner/jobs/logs/report.log 2>&1
```
그리고 `mkdir -p ~/jobs/logs`.

## cron 은 내 터미널이 아니에요
| 터미널 | cron |
|---|---|
| 지금 있는 폴더에서 실행 | **홈 폴더**에서 실행 |
| `.bashrc`, `.profile` 의 PATH·환경 변수 | 읽지 않음. `PATH=/usr/bin:/bin` 정도만 |
| bash | `sh` (dash) |
| 출력이 화면에 | 출력은 (메일 설정이 없으면) **사라짐** → 로그로 꼭 남기기 |
| `%` 는 그냥 문자 | `%` 는 **줄바꿈**으로 바뀜 → `date +\%F` 처럼 이스케이프 |

## 스크립트를 cron 친화적으로 만들기
- **자기 위치 기준으로 파일 찾기**
  - Python: `Path(__file__).resolve().parent / "config.json"`
  - Node.js: `path.join(__dirname, 'config.json')`
- **필요한 환경 변수가 없으면 기본값**: `os.environ.get("REPORT_DIR", "/home/learner/daily-reports")`, `process.env.REPORT_DIR ?? '...'`
- **절대 경로로 실행**: `which python3` → `/usr/bin/python3`. 가상환경이면 `/home/me/venv/bin/python` 을 직접 지정하면 activate 가 필요 없어요.

## 등록 후 확인 습관
1. `crontab -l` 로 저장됐는지
2. 시각을 `* * * * *` (매분) 으로 잠깐 바꿔서 로그가 쌓이는지
3. `grep CRON /var/log/syslog` (서버에 따라 `journalctl -u cron`) 로 실행 기록 확인

`systemd` 를 쓰는 서버라면 **systemd timer** 도 많이 써요. 실패 기록과 로그(`journalctl`)를 자동으로 남겨 줘서 관리가 편해요.
