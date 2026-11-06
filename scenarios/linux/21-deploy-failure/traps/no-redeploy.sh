# 설명: 설정만 고치고 배포를 다시 하지 않으면 서버가 떠 있지 않다
# 실패해야: shop-server 가 실행 중
# 실패해야: 헬스 체크
cd ~
sudo chown learner:learner ~/app/config/app.env
sed -i 's/^PORT=.*/PORT=9000/; s#/publc$#/public#' ~/app/config/app.env
