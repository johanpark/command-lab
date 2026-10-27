`cd ~/hello-site && ls -R` 로 파일 구조를 보고, `nano Dockerfile` 로 첫 줄 `FROM busybox` 부터 시작하세요.
---
폴더 전체를 복사하려면 `COPY . /www`. (Dockerfile 도 같이 복사되는 건 괜찮아요. 신경 쓰이면 `.dockerignore` 에 적으면 돼요)
---
완성된 Dockerfile:
```
FROM busybox
COPY . /www
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
```
`-f` 는 "앞에서(foreground) 실행" 이에요. 없으면 httpd 가 백그라운드로 빠지면서 컨테이너가 바로 종료돼요!
---
`docker build -t hello-site:1.0 .` → `docker run -d --name site -p 8081:80 hello-site:1.0` → `curl http://localhost:8081/about.html`
