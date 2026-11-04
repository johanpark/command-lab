# 설명: 요일을 MON-FRI, 5분마다를 0,5,10,... 으로 써도 맞는 풀이다
# 통과해야
cat > /tmp/my-cron <<'TAB'
30 03 * * * /home/learner/scripts/backup.sh
00 09 * * MON-FRI /home/learner/scripts/report.sh
0,5,10,15,20,25,30,35,40,45,50,55 * * * * /home/learner/scripts/health.sh
TAB
crontab /tmp/my-cron
