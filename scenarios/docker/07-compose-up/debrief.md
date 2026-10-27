# 해설

```bash
cd ~/shop
docker compose up -d       # Error: pull access denied for shop-web (1.O)
docker images              # shop-web 1.0  ← 숫자 0
nano compose.yaml          # image: shop-web:1.0
docker compose up -d       # 둘 다 Up
curl http://localhost:8080 # 안 됨
docker compose logs web    # httpd 는 컨테이너 안에서 80
nano compose.yaml          # ports: - "8080:80"
docker compose up -d       # web 만 다시 만들어짐
curl http://localhost:8080
```

완성된 파일:
```yaml
services:
  web:
    image: shop-web:1.0
    ports:
      - "8080:80"
    depends_on:
      - api
    restart: unless-stopped
  api:
    image: shop-api:2.0
    environment:
      DB_URL: postgres://db.internal:5432/shop
    ports:
      - "3000:3000"
    restart: unless-stopped
```

## docker run 과 비교
```bash
docker run -d --name web -p 8080:80 --restart unless-stopped shop-web:1.0
```
↕ 같은 내용을 파일로 적은 게 compose.yaml 이에요. 명령을 외울 필요 없이 **파일이 곧 문서**가 되고, Git 으로 관리할 수 있어요.

## 자주 쓰는 명령
| 명령 | 뜻 |
|---|---|
| `docker compose up -d` | 만들기/바뀐 것만 다시 만들기 |
| `docker compose ps` / `logs -f` | 상태 / 로그 |
| `docker compose restart api` | 서비스 하나 재시작 |
| `docker compose exec api sh` | 서비스 안으로 들어가기 |
| `docker compose down` | 전부 정지·삭제 (`-v` 붙이면 볼륨까지 삭제 ⚠️) |
| `docker compose config` | 파일 문법 검사 + 최종 설정 보기 |

## 함정 포인트
- `1.O` vs `1.0`, `l` vs `1` 처럼 눈으로 구분이 어려운 오타는 에러 메시지의 **정확한 문자열**을 복사해서 비교하세요.
- YAML 은 **들여쓰기**가 문법이에요. 탭 대신 스페이스, 같은 레벨은 같은 칸 수.
