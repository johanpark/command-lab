# 설명: --restart 를 빼면 서버가 재부팅됐을 때 다시 뜨지 않는다
# 실패해야: 재시작 정책이 unless-stopped
sed -i 's/^LOG_LEVEL=.*/LOG_LEVEL=info/' ~/api.env
docker rm -f api
docker run -d --name api --env-file ~/api.env -p 3000:3000 shop-api:2.0
sleep 1.5
