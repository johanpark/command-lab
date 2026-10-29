#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DNS=ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
# "서버": 같은 컨테이너의 sshd 를 EC2 인 것처럼
id ec2-user >/dev/null 2>&1 || useradd -m -s /bin/bash ec2-user
id ubuntu >/dev/null 2>&1 || useradd -m -s /bin/bash ubuntu     # 있지만 키가 등록 안 된 사용자
grep -q "$DNS" /etc/hosts || echo "127.0.0.1 $DNS" >> /etc/hosts
D="$H/Downloads"; mkdir -p "$D"
rm -f "$D/shop-prod.pem" "$D/shop-prod.pem.pub"
ssh-keygen -q -t rsa -b 2048 -m PEM -N '' -C shop-prod -f "$D/shop-prod.pem"
install -d -m 700 -o ec2-user -g ec2-user /home/ec2-user/.ssh
install -m 600 -o ec2-user -g ec2-user "$D/shop-prod.pem.pub" /home/ec2-user/.ssh/authorized_keys
rm -f "$D/shop-prod.pem.pub"
chmod 644 "$D/shop-prod.pem"      # 브라우저로 내려받은 파일처럼
give "$D"
rel="shop-api $(rand_int 2 4).$(rand_int 0 9).$(rand_int 0 9) build-$(rand_int 1000 9999)"
secret_set release "$rel"
mkdir -p /home/ec2-user/app && echo "$rel" > /home/ec2-user/app/RELEASE && chown -R ec2-user:ec2-user /home/ec2-user/app
mkdir -p /run/sshd
cat > /etc/ssh/sshd_config.d/lab.conf <<'CFG'
ListenAddress 127.0.0.1
PasswordAuthentication no
PermitRootLogin no
CFG
pkill -x sshd 2>/dev/null || true
/usr/sbin/sshd
mkdir -p "$H/.ssh"; chmod 700 "$H/.ssh"; rm -f "$H/.ssh/config" "$H/.ssh/known_hosts"; give "$H/.ssh"
