# 해설

```bash
cd ~/webapp
cat > .dockerignore <<'IGNORE'
.git
.env
.env.*
node_modules
logs
*.log
Dockerfile
.dockerignore
IGNORE
docker build -t webapp:1.1 .
docker images webapp
docker run --rm webapp:1.1 ls -la /app
```

## 빌드 컨텍스트
```
docker build -t 이름 ~/webapp
                      └─ 이 폴더 전체가 Docker 엔진으로 전송됨 (.dockerignore 제외)
```
`.dockerignore` 는 크기만 줄이는 게 아니에요.
- **비밀 유출 방지**: `.env`, `id_rsa`, `credentials.json` 이 이미지에 들어가면 `docker pull` 한 누구나 꺼내 볼 수 있어요.
- **빌드 속도**: 컨텍스트 전송이 빨라지고, 상관없는 파일(로그)이 바뀌어도 캐시가 깨지지 않아요.

## ⚠️ 이미 올라간 이미지는?
`webapp:1.0` 을 레지스트리에 push 했다면 `.env` 의 비밀번호는 **이미 유출된 것**으로 보고 바꿔야 해요. 이미지를 지워도 누군가 받아 갔을 수 있어요. 이전 층(layer)에 남은 파일도 `docker history` / `docker save` 로 꺼낼 수 있어서, 나중 층에서 `rm` 해도 소용없어요.

## 더 줄이려면
| 방법 | 효과 |
|---|---|
| `COPY public ./public` 처럼 **필요한 것만** COPY | 실수로 새 파일이 들어갈 일이 없음 |
| **멀티 스테이지 빌드** | 빌드 도구는 1단계에서만 쓰고, 결과물만 작은 이미지로 |
| 작은 베이스 이미지 (`alpine`, `distroless`, `busybox`) | 수백 MB → 수 MB |
| `RUN` 을 합치고 같은 층에서 캐시 지우기 | 층마다 남는 찌꺼기 줄이기 |
