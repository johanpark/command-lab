# 해설

```bash
docker ps --filter publish=8080 --format '{{.Names}}' > ~/answer.txt
docker rm -f "$(cat ~/answer.txt)"
docker run -d --name shop -p 8080:80 --restart unless-stopped shop-web:2.0
curl -s localhost:8080
```

## 포트는 한 번에 하나만
호스트의 포트 하나는 **한 프로그램만** 쓸 수 있어요. 컨테이너가 `-p 8080:80` 으로 잡고 있으면 다른 컨테이너도, 호스트의 다른 프로그램도 8080 을 못 써요.

| 누가 잡았나 찾기 | 명령 |
|---|---|
| 컨테이너 | `docker ps --filter publish=8080` |
| 호스트의 일반 프로그램 | `sudo ss -ltnp 'sport = :8080'` 또는 `sudo lsof -i :8080` (Linux 의 "포트가 이미 사용 중입니다" 시나리오) |
| Windows | `netstat -ano \| findstr :8080` |

## 테스트 컨테이너가 남지 않게
- 잠깐 띄워 볼 땐 `docker run --rm ...` → 멈추면 저절로 지워져요.
- 이름에 용도를 남기세요: `--name test-shop-kim` (누가 왜 띄웠는지 알 수 있게)
- 운영 서버에서 손으로 띄우는 대신 compose 파일로 관리하면 "누가 띄운 거지?" 가 줄어요.

## 무중단 배포라면
이번처럼 지우고 띄우면 잠깐 서비스가 끊겨요. 실무에서는 새 버전을 **다른 포트**에 먼저 띄워 확인한 뒤 로드밸런서(nginx 등)가 가리키는 곳을 바꾸는 방식(블루-그린)을 많이 써요.
