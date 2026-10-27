`docker exec app ping -c 1 db` 를 해 보세요. `bad address 'db'` — `db` 라는 이름을 모른대요. 두 컨테이너가 어느 네트워크에 있는지 `docker inspect app --format '{{json .NetworkSettings.Networks}}'` 로 보세요.
---
둘 다 기본 `bridge` 네트워크에 있어요. 기본 bridge 에서는 **컨테이너 이름으로 서로를 찾을 수 없어요** (IP 로만 가능). 직접 만든 네트워크에서는 이름으로 찾을 수 있습니다.
---
`docker network create shop-net` → `docker network connect shop-net db` → `docker network connect shop-net app`
---
`docker logs --tail 3 app` 으로 확인. 몇 초 안에 `OK connected to db` 가 나와야 해요. `docker network inspect shop-net` 에 두 컨테이너가 보이는지도 확인!
