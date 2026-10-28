# 해설

```bash
docker ps --filter health=unhealthy --format '{{.Names}}' > ~/answer.txt
n=$(cat ~/answer.txt)
docker inspect -f '{{json .State.Health}}' $n     # wget: server returned error: HTTP/1.1 404
docker logs $n                                    # WARN unknown APP_MODE 'prodution'
docker inspect -f '{{.Config.Image}} {{.HostConfig.PortBindings}} {{.HostConfig.RestartPolicy.Name}}' $n
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' $n
docker rm -f $n
docker run -d --name $n -p 1808x:8080 --restart unless-stopped \
  -e APP_MODE=production -e DB_HOST=db.internal -e TZ=Asia/Seoul app-server:3.2
```

## Up 인데 장애?
`Up` 은 "프로세스가 살아 있다"는 뜻일 뿐이에요. 웹 서버가 떠 있어도 DB 에 못 붙거나, 설정이 틀려 요청을 못 받을 수 있어요. 그래서 **헬스체크**로 "일을 할 수 있는 상태인지"를 확인해요.

```dockerfile
HEALTHCHECK --interval=3s --timeout=2s --retries=2 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
```
- 종료 코드 0 = 정상, 1 = 실패. `retries` 번 연속 실패하면 `unhealthy`.
- compose 의 `depends_on: condition: service_healthy`, 쿠버네티스의 readiness/liveness probe 도 같은 아이디어예요.

## restart 로는 안 되는 이유
`docker restart` 는 **같은 설정**으로 프로세스만 다시 띄워요. 환경 변수, 포트, 볼륨, 메모리 상한은 `docker run` 때 정해져서 바꾸려면 다시 만들어야 해요. 그래서 실무에서는 `docker run` 명령을 손으로 치지 않고 **compose 파일이나 스크립트**로 남겨 두는 거예요.
