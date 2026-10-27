`docker ps` 로 legacy-app 이 실행 중인지 보고, `docker exec legacy-app cat /etc/legacy/app.conf` 로 설정을 보세요.
---
환경 변수는 두 군데서 볼 수 있어요: `docker exec legacy-app env` (지금 컨테이너 안의 값) 또는 `docker inspect -f '{{.Config.Env}}' legacy-app` (만들 때 준 값)
---
`docker exec legacy-app env | grep '^TZ='` 처럼 걸러 보세요. 값만 저장하려면 `cut -d= -f2`
---
`docker cp legacy-app:/var/log/legacy/error.log ~/error.log`. 내 서버에서 `head ~/error.log` 로 확인!
