첫 에러는 키 파일 권한이에요. ssh 는 개인키를 **나 말고 다른 사람이 읽을 수 있으면** 아예 쓰지 않아요. `chmod 400 ~/Downloads/shop-prod.pem`
---
권한을 고쳐도 `Permission denied (publickey)` 가 나오나요? 사용자 이름이 틀렸어요. EC2 는 OS(AMI)마다 기본 사용자가 달라요. **Amazon Linux 는 `ec2-user`**, Ubuntu 는 `ubuntu`, Debian 은 `admin` 이에요. root 로는 들어갈 수 없어요.
---
처음 접속하면 `Are you sure you want to continue connecting (yes/no)?` 를 물어봐요. 새 서버의 지문(fingerprint)을 기억할지 묻는 거라 `yes`. 파일 읽기: `ssh -i ~/Downloads/shop-prod.pem ec2-user@ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com 'cat ~/app/RELEASE' > ~/answer.txt`
---
`~/.ssh/config` 에:
```
Host shop-prod
    HostName ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
    User ec2-user
    IdentityFile ~/Downloads/shop-prod.pem
```
확인: `ssh shop-prod 'hostname'`
