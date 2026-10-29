chmod 400 ~/Downloads/shop-prod.pem
DNS=ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
ssh -o StrictHostKeyChecking=accept-new -i ~/Downloads/shop-prod.pem ec2-user@$DNS 'cat ~/app/RELEASE' > ~/answer.txt
cat >> ~/.ssh/config <<CFG
Host shop-prod
    HostName $DNS
    User ec2-user
    IdentityFile ~/Downloads/shop-prod.pem
CFG
ssh shop-prod hostname
