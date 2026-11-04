# 설명: crontab 변수 줄의 $HOME 은 풀리지 않아 보고서가 엉뚱한 곳에 생긴다
# 실패해야: ~/daily-reports 에 보고서
mkdir -p ~/jobs/logs
crontab - <<'CRON'
REPORT_DIR=$HOME/daily-reports
*/30 * * * * cd /home/learner/jobs && /usr/bin/python3 cleanup.py >> /home/learner/jobs/logs/cleanup.log 2>&1
30 7 * * * /usr/bin/node /home/learner/jobs/daily_report.js >> /home/learner/jobs/logs/report.log 2>&1
CRON
