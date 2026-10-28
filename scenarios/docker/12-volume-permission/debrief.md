# 해설

```bash
docker exec uploader id            # uid=1000
ls -ldn /srv/uploads               # 소유자 0(root), 755
sudo chown -R 1000:1000 /srv/uploads
docker logs --tail 3 uploader      # OK heartbeat ...
```

## 컨테이너와 호스트는 uid 를 공유해요
컨테이너 안의 `app` 사용자와 호스트의 `learner` 는 이름이 달라도 **uid 가 같으면 같은 사용자**로 취급돼요. bind mount(`-v /호스트경로:/컨테이너경로`) 는 파일을 복사하지 않고 그대로 보여 주기 때문에, 권한 검사도 호스트 파일의 uid/gid 와 권한 비트로 해요.

## 해결 방법 비교
| 방법 | 평가 |
|---|---|
| `chown 1000:1000 폴더` | ✅ 컨테이너 사용자만 쓰기 |
| 공유 그룹을 만들어 `chgrp` + `chmod 2775` | ✅ 여러 사용자·컨테이너가 같이 써야 할 때 |
| `--user $(id -u):$(id -g)` 로 실행 | ✅ 내 uid 로 돌리기 (개발 환경에서 흔함) |
| **named volume** (`-v uploads:/data/uploads`) | ✅ Docker 가 만든 볼륨은 이미지 안 폴더의 소유자를 따라감 |
| `chmod 777` | ❌ 아무나 쓰기. 다른 침입 경로가 생김 |
| `--user root` | ❌ 이미지가 일부러 막아 둔 root 권한을 다시 열어 줌 |

## Dockerfile 쪽에서는
```dockerfile
RUN addgroup -S -g 1000 app && adduser -S -u 1000 -G app app \
 && mkdir -p /data/uploads && chown app:app /data/uploads
USER app
```
이렇게 이미지를 만들고 **named volume** 을 쓰면 처음부터 권한이 맞아요. 호스트 경로를 꼭 써야 한다면 배포 스크립트에 `chown` 을 같이 넣어 두세요.
