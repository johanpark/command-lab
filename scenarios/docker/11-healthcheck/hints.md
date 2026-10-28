`docker ps --filter health=unhealthy --format '{{.Names}}'` 로 이름을 찾을 수 있어요.
---
`docker inspect -f '{{json .State.Health}}' 이름` 에서 `Output` 을 보면 헬스체크가 왜 실패하는지 나와요. 이어서 `docker logs 이름` 으로 앱이 시작할 때 무슨 말을 했는지 보세요.
---
로그에 `unknown APP_MODE` 가 보이죠? 환경 변수에 **오타**가 있어요. 그런데 `docker restart` 로는 환경 변수가 안 바뀌어요. 환경 변수는 컨테이너를 **만들 때** 정해지거든요. 지우고 다시 만들어야 해요.
---
다시 만들기 전에 원래 설정을 적어 두세요: `docker inspect -f '{{.Config.Image}} {{.HostConfig.PortBindings}} {{.HostConfig.RestartPolicy.Name}}' 이름` 과 `{{.Config.Env}}`. 그다음 `docker rm -f 이름` → `docker run -d --name 이름 -p 포트:8080 --restart 정책 -e APP_MODE=production -e 다른변수=값 ... 이미지`. 10초쯤 뒤 `docker ps` 에서 `(healthy)` 확인!
