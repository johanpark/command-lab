# Docker 가 디스크를 다 먹었어요

빌드와 테스트를 몇 달 돌렸더니 Docker 가 디스크를 잔뜩 차지하고 있어요. 정리하되, **지금 서비스 중인 것은 건드리면 안 됩니다.**

## 목표
1. `docker system df` 로 무엇이 공간을 차지하는지 확인하세요.
2. **멈춘(Exited) 컨테이너**를 모두 지우세요.
3. **이름 없는(`<none>`) 이미지**를 모두 지우세요.
4. **아무 컨테이너도 쓰지 않는 볼륨**을 모두 지우세요.

## 반드시 지킬 것
- 실행 중인 `web` 컨테이너, 그 이미지 `shop-web:1.0`, 그 데이터 볼륨 `web-data`
- 비상용으로 보관 중인 이미지 **`backup-tool:1.0`** (지금은 안 쓰지만 지우면 안 돼요)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker system df` | 이미지/컨테이너/볼륨이 쓰는 공간 |
| `docker ps -a --filter status=exited` | 멈춘 컨테이너만 |
| `docker images --filter dangling=true` | 이름 없는 이미지만 |
| `docker volume ls --filter dangling=true` | 안 쓰는 볼륨만 |
| `docker container prune` / `docker image prune` / `docker volume prune` | 종류별 정리 (확인을 물어요) |

> ⚠️ `prune` 은 되돌릴 수 없어요. 먼저 `--filter` 로 **무엇이 지워질지** 확인하는 습관!
