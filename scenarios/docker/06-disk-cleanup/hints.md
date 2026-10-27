`docker system df` 의 RECLAIMABLE 열이 "지워도 되는" 양이에요. 하나씩 목록부터 보세요: `docker ps -a --filter status=exited`, `docker images --filter dangling=true`, `docker volume ls --filter dangling=true`
---
멈춘 컨테이너: `docker container prune`. 이름 없는 이미지: `docker image prune`. 둘 다 `y` 로 확인하면 돼요.
---
⚠️ `docker image prune -a` 나 `docker system prune -a` 는 **안 쓰는 이미지 전부**를 지워요. `backup-tool:1.0` 까지 사라집니다. `-a` 없이!
---
볼륨은 함정이 있어요. 요즘 Docker 의 `docker volume prune` 은 **이름 없는(익명) 볼륨만** 지워요. 이름 붙은 안 쓰는 볼륨까지 지우려면 `docker volume prune -a`. 실행 중인 컨테이너가 쓰는 `web-data` 는 안전해요. 마지막에 `docker volume ls --filter dangling=true` 가 비었는지 확인!
