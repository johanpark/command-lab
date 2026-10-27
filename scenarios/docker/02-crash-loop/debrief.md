# 해설

```bash
docker ps -a                       # STATUS: Restarting (1)
docker logs api                    # FATAL environment variable DB_URL is not set (반복)
docker inspect api --format '{{.Config.Env}}'   # DB_URL 이 없음
docker rm -f api
docker run -d --name api --env-file ~/api.env -p 3000:3000 --restart unless-stopped shop-api:2.0
docker logs api                    # FATAL invalid LOG_LEVEL 'verbose'
nano ~/api.env                     # LOG_LEVEL=info
docker rm -f api
docker run -d --name api --env-file ~/api.env -p 3000:3000 --restart unless-stopped shop-api:2.0
curl http://localhost:3000/health  # ok
```

## 기억할 것
- **Restarting / Exited (1)** 를 보면 무조건 `docker logs` 부터. 컨테이너는 대부분 "왜 죽는지" 마지막 말을 남겨요.
- 컨테이너의 환경 변수·포트·볼륨은 **만들 때 정해집니다.** 바꾸려면 지우고 다시 만들어요. (그래서 `docker run` 명령을 스크립트나 Compose 파일로 남겨 두는 거예요)
- 비밀 값(`API_KEY`)을 `-e` 로 명령줄에 직접 쓰면 셸 기록에 남아요. `--env-file` 이 더 안전합니다.

## 재시작 정책
| 정책 | 언제 다시 띄우나 |
|---|---|
| `no` (기본) | 안 띄움 |
| `on-failure[:횟수]` | 에러로 죽었을 때만 |
| `always` | 항상 (직접 stop 해도 Docker 재시작 시 다시 뜸) |
| `unless-stopped` | 항상, 단 **직접 stop 한 건 그대로 둠** ← 보통 이걸 씀 |
