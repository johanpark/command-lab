# 설명: 640 은 그룹이 키를 읽을 수 있어 ssh 가 키를 거부한다
# 실패해야: 키 파일을 나만 읽을 수 있다
chmod 640 ~/Downloads/shop-prod.pem
