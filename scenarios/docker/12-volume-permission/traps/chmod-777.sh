# 설명: chmod 777 로 열면 써지긴 하지만 아무나 쓸 수 있게 된다
# 실패해야: 아무나 쓸 수 있는(777)
sudo chmod -R 777 /srv/uploads
sleep 4
