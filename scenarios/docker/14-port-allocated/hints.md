`docker ps` 의 **PORTS** 열을 보세요. `0.0.0.0:8080->80/tcp` 처럼 `바깥포트->안포트` 로 나와요. 화면이 넓어서 잘리면 `docker ps --format '{{.Names}}\t{{.Ports}}'`
---
더 빠르게: `docker ps --filter publish=8080 --format '{{.Names}}'`. 이 이름을 `~/answer.txt` 에 저장하세요.
---
`docker rm -f 그이름` → `docker run -d --name shop -p 8080:80 --restart unless-stopped shop-web:2.0`
---
`curl -s localhost:8080` 에 `v2.0` 이 보이면 성공! `docker ps` 로 다른 컨테이너(admin, api)가 그대로인지도 확인하세요.
