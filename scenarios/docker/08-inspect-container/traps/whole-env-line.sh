# 설명: env | grep TZ 를 그대로 저장하면 'TZ=' 까지 들어간다 (값만 적어야 함)
# 실패해야: 환경 변수 TZ 값
docker exec legacy-app cat /etc/legacy/app.conf | grep '^DB_HOST=' | cut -d= -f2 > ~/answer.txt
docker exec legacy-app env | grep '^TZ=' > ~/tz.txt
docker cp legacy-app:/var/log/legacy/error.log ~/error.log
