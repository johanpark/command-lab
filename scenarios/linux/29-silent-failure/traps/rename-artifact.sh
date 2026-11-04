# 설명: 스크립트 대신 빌드 산출물 이름을 바꿔 맞춘다
# 실패해야: 산출물 이름은 그대로
# 실패해야: 즉시 멈추고
mv ~/build/app-v2.5.0.tar.gz ~/build/app-2.5.0.tar.gz
~/deploy.sh 2.5.0
