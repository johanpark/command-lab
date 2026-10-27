cat > /tmp/my-cron <<'TAB'
30 3 * * * /home/learner/scripts/backup.sh
0 9 * * 1-5 /home/learner/scripts/report.sh
*/5 * * * * /home/learner/scripts/health.sh >> /home/learner/scripts/health.log 2>&1
TAB
crontab /tmp/my-cron
