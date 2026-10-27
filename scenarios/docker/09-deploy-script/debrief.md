# 해설

```bash
#!/usr/bin/env bash
set -e
VERSION=${1:?사용법: ./deploy.sh <버전>}
echo "▶ shop-web:$VERSION 배포"
docker rm -f web 2>/dev/null || true          # 있으면 지우고, 없으면 그냥 통과
docker run -d --name web -p 8080:80 --restart unless-stopped "shop-web:$VERSION"
echo "✅ 배포 완료 (shop-web:$VERSION)"
```

## 멱등성(idempotency)
"**몇 번을 실행해도 같은 결과**"가 나오는 성질이에요. 배포·설치 스크립트는 중간에 실패해서 다시 돌리는 일이 잦기 때문에 꼭 갖춰야 해요.
| 멱등하지 않음 | 멱등함 |
|---|---|
| `mkdir dir` | `mkdir -p dir` |
| `docker run --name web` | `docker rm -f web \|\| true` 후 `docker run` |
| `echo 'x' >> config` | `grep -qx 'x' config \|\| echo 'x' >> config` |
| `useradd kim` | `id kim \|\| useradd kim` |

## 함정 포인트: set -e 와 "실패해도 되는" 명령
`docker stop web && docker rm web` 은 `web` 이 없으면 실패해요. 그러면 `set -e` 가 스크립트를 멈춰서 **새 컨테이너를 띄우지도 못해요.**

| 명령 (`web` 이 없을 때) | 종료 코드 |
|---|---|
| `docker stop web` | 1 (실패) |
| `docker rm web` | 1 (실패) |
| `docker rm -f web` | 최신 Docker: 0 / 옛 버전: 1 |
| `docker rm -f web 2>/dev/null \|\| true` | 항상 0 ✅ |

`set -e` 를 지우면 쉽게 되지만, 그러면 진짜 실패(이미지 없음, 포트 충돌)도 무시하고 "배포 완료"를 출력해요(`linux/29` 시나리오). 실패해도 되는 명령에만 `|| true` 를 붙이는 게 정석이에요.

## 더 나은 배포
- 지금 방식은 `rm` 과 `run` 사이에 **잠깐 서비스가 끊겨요.** 무중단으로 하려면 새 컨테이너를 다른 포트로 띄우고 헬스 체크 후 프록시를 전환하는 방식(블루/그린)을 써요.
- `docker compose up -d` 는 이런 "있으면 교체" 를 알아서 해 줘요.
