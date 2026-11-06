# 설명: 640·750 은 그룹이 아직 읽을 수 있다
# 실패해야: api.key 권한이 600
# 실패해야: secrets 폴더 권한이 700
chmod +x ~/deploy.sh && cd ~ && ./deploy.sh
chmod 640 ~/secrets/api.key
chmod 750 ~/secrets
