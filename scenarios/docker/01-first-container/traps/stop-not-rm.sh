# 설명: old-web 을 stop 만 하면 컨테이너는 그대로 남는다
# 실패해야: old-web 컨테이너를 삭제
docker run -d --name web -p 8080:80 shop-web:1.0
sleep 1
curl -s http://localhost:8080 | grep -o 'SHOP-[0-9]*' > ~/answer.txt
docker stop old-web
