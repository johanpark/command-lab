`docker images` 로 `shop-web:1.0` 이 있는지, `docker ps -a` 로 지금 컨테이너들이 어떤 상태인지(Up / Exited) 보세요.
---
`docker run -d --name web -p 8080:80 shop-web:1.0`. 실행 후 `docker ps` 의 PORTS 열에 `0.0.0.0:8080->80/tcp` 가 보이면 성공이에요.
---
`curl http://localhost:8080` 출력에서 코드를 찾아 `echo 코드 > ~/answer.txt`. 이름이 이미 쓰인다는 에러가 나면 `docker rm -f web` 후 다시!
---
`docker rm old-web`. 멈춰 있는 컨테이너라 바로 지워져요. (실행 중인 걸 지우려면 `docker rm -f`)
