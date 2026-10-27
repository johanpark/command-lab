`docker logs api` 를 보세요. 같은 에러가 반복되죠? 컨테이너가 죽을 때마다 재시작 정책 때문에 다시 살아났다가 또 죽는 거예요.
---
첫 번째 원인은 환경 변수가 **아예 전달되지 않은 것**이에요. `docker inspect api --format '{{.Config.Env}}'` 로 확인해 보세요. 고치려면 지우고(`docker rm -f api`) `--env-file ~/api.env` 를 붙여서 다시 만들어야 해요.
---
`docker run -d --name api --env-file ~/api.env -p 3000:3000 --restart unless-stopped shop-api:2.0`. 그다음 `docker logs api` 를 다시 보세요. 새 에러가 나오면 `~/api.env` 를 고칠 차례예요.
---
`LOG_LEVEL` 에 허용되지 않는 값이 들어 있어요. 로그가 알려주는 값 중 하나로 `nano ~/api.env` 에서 고치고, 컨테이너를 **다시 만드세요** (`docker rm -f api` 후 같은 run 명령).
