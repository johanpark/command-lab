# 배포 스크립트가 두 번째부터 실패해요

`~/deploy.sh <버전>` 으로 웹 서버 컨테이너를 배포합니다. 지금은 **1.0** 이 떠 있어요. 1.1 을 배포하려고 하니:

```
$ ./deploy.sh 1.1
▶ shop-web:1.1 배포
docker: Error response from daemon: Conflict. The container name "/web" is already in use by container "3f2a...".
```

이 스크립트는 처음 한 번만 돼요. 이미 `web` 이 있으면 실패합니다.

## 목표
1. **1.1 을 배포**하세요. `curl http://localhost:8080` 이 `v1.1` 을 보여줘야 해요.
2. `deploy.sh` 를 고쳐서 **몇 번을 실행해도** 성공하게 하세요.
   - `web` 이 이미 있으면 → 지우고 새 버전으로
   - `web` 이 아예 없을 때도 → 그냥 새로 띄우기 (여기서 실패하면 안 돼요!)
3. `set -e` 는 그대로 두세요. (실패를 무시하는 스크립트는 더 위험해요)

> 채점할 때 실제로 `deploy.sh` 를 여러 번, `web` 이 있을 때와 없을 때 모두 실행해 봅니다.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker ps -a` | 지금 있는 컨테이너 |
| `docker stop web` / `docker rm web` | 멈추기 / 삭제 (없으면 에러) |
| `docker rm -f web` | 실행 중이어도 강제 삭제 |
| `명령 \|\| true` | 명령이 실패해도 성공으로 취급 |
| `명령 2>/dev/null` | 에러 메시지 숨기기 |
| `docker images shop-web` | 배포할 수 있는 버전들 |
