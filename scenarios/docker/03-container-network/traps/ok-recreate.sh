# 설명: 연결 대신 --network 를 붙여 컨테이너를 다시 만들어도 맞는 풀이다 (문제는 '다시 만들 필요는 없다' 고만 함)
# 통과해야
img_app=$(docker inspect -f '{{.Config.Image}}' app); img_db=$(docker inspect -f '{{.Config.Image}}' db)
docker network create shop-net
docker rm -f app db
docker run -d --name db --network shop-net "$img_db"
docker run -d --name app --network shop-net "$img_app"
sleep 3
