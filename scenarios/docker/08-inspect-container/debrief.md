# 해설

```bash
docker exec legacy-app cat /etc/legacy/app.conf
docker exec legacy-app cat /etc/legacy/app.conf | grep DB_HOST | cut -d= -f2 > ~/answer.txt
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' legacy-app
docker exec legacy-app printenv TZ > ~/tz.txt
docker cp legacy-app:/var/log/legacy/error.log ~/error.log
```

## inspect 로 자주 꺼내는 정보
```bash
docker inspect -f '{{.Config.Image}}' legacy-app                      # 이미지
docker inspect -f '{{json .Config.Env}}' legacy-app                   # 환경 변수
docker inspect -f '{{json .HostConfig.PortBindings}}' legacy-app      # 포트
docker inspect -f '{{json .Mounts}}' legacy-app                       # 볼륨
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' legacy-app     # 재시작 정책
docker inspect legacy-app | jq '.[0].Config.Cmd'                      # jq 로 골라 보기
```

## 이전(마이그레이션) 할 때 체크리스트
이 정보들로 새 서버에서 같은 `docker run` 명령(또는 compose.yaml)을 다시 만들 수 있어요: **이미지, 환경 변수, 포트, 볼륨, 재시작 정책, 네트워크**.

## exec 할 때 주의
- `docker exec -it ... sh` 안에서 고친 것은 **컨테이너를 다시 만들면 사라져요.** 진짜 수정은 이미지나 설정(볼륨, 환경 변수)으로.
- busybox/alpine 기반은 `bash` 가 없고 `sh` 만 있는 경우가 많아요.
