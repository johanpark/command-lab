# 설명: bash deploy.sh 로 돌리면 배포는 되지만 실행 권한은 그대로 없다
# 실패해야: 실행 권한이 있다
cd ~ && bash deploy.sh
chmod 600 ~/secrets/api.key
chmod 700 ~/secrets
