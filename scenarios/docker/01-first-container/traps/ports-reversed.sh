# 설명: -p 80:8080 처럼 순서를 뒤집으면 호스트 8080 에 연결되지 않는다
# 실패해야: 8080 포트가 컨테이너의 80
# 실패해야: curl http://localhost:8080
docker run -d --name web -p 80:8080 shop-web:1.0
docker rm -f old-web
