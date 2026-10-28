`docker run --rm webapp:1.0 ls -la /app` 와 `du -sh ~/webapp/* ~/webapp/.[!.]*` 를 비교해 보세요. 무엇이 크고, 무엇이 이미지에 들어가면 안 되는지 보여요.
---
`docker build` 는 시작할 때 폴더 전체(**빌드 컨텍스트**)를 Docker 엔진에 보내요. `COPY . .` 은 그걸 통째로 넣고요. `.dockerignore` 파일에 적은 경로는 **아예 보내지 않아요.** (`.gitignore` 와 비슷한 문법)
---
`~/webapp/.dockerignore` 에 한 줄씩:
```
.git
.env
node_modules
logs
```
`.env` 는 숨김 파일이라 `ls` 로는 안 보여요. 꼭 넣으세요!
---
`docker build -t webapp:1.1 ~/webapp` → `docker images webapp` 로 크기 비교 → `docker run --rm webapp:1.1 ls -la /app` 로 확인. (Dockerfile 을 `COPY public ./public` 으로 바꾸는 방법도 좋아요. 둘 다 하면 더 좋고요)
