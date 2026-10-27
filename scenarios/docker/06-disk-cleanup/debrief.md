# 해설

```bash
docker system df                       # RECLAIMABLE 확인
docker ps -a --filter status=exited    # 지워질 컨테이너 미리 보기
docker container prune
docker images --filter dangling=true
docker image prune                     # -a 없이!
docker volume ls --filter dangling=true
docker volume prune -a                 # 이름 붙은 안 쓰는 볼륨까지
docker system df                       # 줄어든 것 확인
```

## prune 정리
| 명령 | 지우는 것 |
|---|---|
| `docker container prune` | 멈춘 컨테이너 |
| `docker image prune` | 이름 없는(dangling) 이미지 |
| `docker image prune -a` | **컨테이너가 안 쓰는 이미지 전부** (태그 있어도!) ⚠️ |
| `docker volume prune` | 안 쓰는 **익명** 볼륨 (Docker 23 부터) |
| `docker volume prune -a` | 안 쓰는 볼륨 전부 (이름 있어도) ⚠️ |
| `docker system prune` | 위의 컨테이너 + dangling 이미지 + 안 쓰는 네트워크 + 빌드 캐시 |

## 이름 없는 이미지는 왜 생길까?
같은 태그(`report:latest`)로 다시 빌드하면, 태그가 새 이미지로 옮겨가고 **예전 이미지는 이름을 잃어요.** CI 에서 빌드를 반복하면 계속 쌓입니다.

## 함정 포인트
- `-a` 붙은 prune 은 "지금 안 쓰는 것"을 다 지워요. 비상용 이미지, 다음 배포에 쓸 이미지까지. **운영 서버에서는 `-a` 전에 목록 확인 필수.**
- 볼륨에는 DB 같은 **진짜 데이터**가 들어 있을 수 있어요. 컨테이너를 잠깐 지운 사이에 `volume prune -a` 를 하면 데이터가 사라집니다.
