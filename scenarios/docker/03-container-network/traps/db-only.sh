# 설명: db 만 네트워크에 넣고 app 은 빼먹는다
# 실패해야: app 이 shop-net 에 연결
# 실패해야: db:5000 에 접속
docker network create shop-net
docker network connect shop-net db
