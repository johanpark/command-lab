docker network create shop-net
docker network connect shop-net db
docker network connect shop-net app
sleep 3
docker logs --tail 1 app
