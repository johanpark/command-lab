docker logs api 2>&1 | tail -n 3
sed -i 's/^LOG_LEVEL=.*/LOG_LEVEL=info/' ~/api.env
docker rm -f api
docker run -d --name api --env-file ~/api.env -p 3000:3000 --restart unless-stopped shop-api:2.0
sleep 1.5
