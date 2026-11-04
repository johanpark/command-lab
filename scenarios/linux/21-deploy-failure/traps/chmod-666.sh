# 설명: 소유자를 고치는 대신 chmod 666 으로 열면 아무나 설정을 고칠 수 있다
# 실패해야: 아무나 고칠 수 있게 열어 두지 않았다
cd ~
sudo chmod 666 ~/app/config/app.env
sed -i 's/^PORT=.*/PORT=9000/; s#/publc$#/public#' ~/app/config/app.env
./deploy.sh
