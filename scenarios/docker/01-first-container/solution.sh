docker run -d --name web -p 8080:80 shop-web:1.0
sleep 1
curl -s http://localhost:8080 | grep -o 'SHOP-[0-9]*' > ~/answer.txt
docker rm old-web
