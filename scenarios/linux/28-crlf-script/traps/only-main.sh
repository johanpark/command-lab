# 설명: deploy.sh 만 고치면 lib 폴더의 스크립트에 CRLF 가 남아 배포가 실패한다
# 실패해야: CRLF(\r)를 없앴다
# 실패해야: 배포가 완료됐다
cd ~/deploy
sed -i 's/\r$//' deploy.sh
./deploy.sh
