mkdir -p ~/jobs/logs
crontab - <<'CRON'
REPORT_DIR=/home/learner/daily-reports
*/30 * * * * cd /home/learner/jobs && /usr/bin/python3 cleanup.py >> /home/learner/jobs/logs/cleanup.log 2>&1
30 7 * * * /usr/bin/node /home/learner/jobs/daily_report.js >> /home/learner/jobs/logs/report.log 2>&1
CRON
crontab -l
