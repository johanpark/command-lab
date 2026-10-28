# port is already allocated

쇼핑몰 2.0 배포 날이에요. 로드밸런서가 이 서버의 **8080 포트**로 손님을 보내도록 설정돼 있어서, 새 버전도 8080 에 띄워야 해요.

```
$ docker run -d --name shop -p 8080:80 shop-web:2.0
docker: Error response from daemon: ... Bind for 0.0.0.0:8080 failed: port is already allocated.
```

누가 8080 을 쓰고 있을까요? 컨테이너가 여러 개 떠 있어서 한눈에는 모르겠어요. 어제 누가 **테스트하다 남긴 컨테이너**라는 소문이 있어요.

## 목표
1. **8080 을 잡고 있는 컨테이너 이름**을 `~/answer.txt` 에 저장하세요.
2. 그 컨테이너를 **지우세요.** (다른 컨테이너는 서비스 중이니 건드리지 마세요)
3. **`shop`** 이라는 이름으로 **`shop-web:2.0`** 을 **8080 → 80** 으로 띄우세요. 서버가 재부팅돼도 다시 뜨게 `--restart unless-stopped` 도 붙이세요.

> 포트를 8090 같은 다른 번호로 바꾸면 안 돼요. 로드밸런서는 8080 만 봐요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker ps` | 실행 중인 컨테이너 (PORTS 열에 `0.0.0.0:8080->80/tcp`) |
| `docker ps --filter publish=8080` | 8080 을 연결한 컨테이너만 |
| `docker port 이름` | 그 컨테이너의 포트 연결 |
| `docker rm -f 이름` | 멈추고 지우기 |
| `curl -s localhost:8080` | 확인 |
