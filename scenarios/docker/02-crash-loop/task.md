# 계속 재시작하는 컨테이너

API 서버 컨테이너 `api` 가 이상합니다. `docker ps` 를 볼 때마다 상태가 `Restarting` 이에요.

```
CONTAINER ID   IMAGE          STATUS                          NAMES
3f2a1b...      shop-api:2.0   Restarting (1) 3 seconds ago    api
```

운영팀이 설정 값은 `~/api.env` 에 정리해 뒀다고 합니다.

## 목표
1. 로그에서 컨테이너가 죽는 **원인**을 찾으세요. (하나를 고치면 다음 원인이 보일 수도 있어요)
2. `api` 컨테이너를 **다시 만들어서** 정상 실행되게 하세요.
   - 이미지 `shop-api:2.0`, 이름 `api`
   - 설정은 `~/api.env` 파일로 전달
   - 포트 **3000:3000**
   - 서버가 재부팅돼도 다시 뜨도록 재시작 정책 **`unless-stopped`**
3. `curl http://localhost:3000/health` 가 `ok` 를 돌려줘야 합니다.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker ps -a` | 상태 확인 (Up / Restarting / Exited) |
| `docker logs api` | 컨테이너가 남긴 출력 |
| `docker inspect api --format '{{.Config.Env}}'` | 설정된 환경 변수 |
| `docker run --env-file 파일 ...` | 파일의 `KEY=값` 들을 환경 변수로 |
| `docker run --restart unless-stopped ...` | 재시작 정책 |
| `docker rm -f api` | 실행 중이어도 강제 삭제 |

> 💡 컨테이너의 설정(환경 변수, 포트)은 **실행 중에 바꿀 수 없어요.** 지우고 새로 만들어야 합니다.
