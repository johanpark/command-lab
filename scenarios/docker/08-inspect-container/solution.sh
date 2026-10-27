docker exec legacy-app cat /etc/legacy/app.conf | grep '^DB_HOST=' | cut -d= -f2 > ~/answer.txt
docker exec legacy-app env | grep '^TZ=' | cut -d= -f2 > ~/tz.txt
docker cp legacy-app:/var/log/legacy/error.log ~/error.log
