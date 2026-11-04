# 설명: Amazon Linux 의 기본 사용자는 ubuntu 가 아니라 ec2-user 다
# 실패해야: shop-prod 별칭이 있다
# 실패해야: ssh shop-prod 만으로
chmod 400 ~/Downloads/shop-prod.pem
DNS=ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
ssh -o StrictHostKeyChecking=accept-new -i ~/Downloads/shop-prod.pem ec2-user@$DNS 'cat ~/app/RELEASE' > ~/answer.txt
cat >> ~/.ssh/config <<CFG
Host shop-prod
    HostName $DNS
    User ubuntu
    IdentityFile ~/Downloads/shop-prod.pem
CFG
