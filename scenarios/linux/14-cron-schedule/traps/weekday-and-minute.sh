# 설명: 분 자리를 * 로 두면 9시에 60번, 요일 0-4 는 일~목이다
# 실패해야: report.sh: 평일 09:00
# 실패해야: backup.sh: 매일 03:30
cat > /tmp/my-cron <<'TAB'
3 30 * * * /home/learner/scripts/backup.sh
* 9 * * 0-4 /home/learner/scripts/report.sh
*/5 * * * * /home/learner/scripts/health.sh
TAB
crontab /tmp/my-cron
