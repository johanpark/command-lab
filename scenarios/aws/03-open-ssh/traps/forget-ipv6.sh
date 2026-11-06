# 설명: IPv4(0.0.0.0/0)만 막고 IPv6(::/0) 규칙을 잊으면 SSH 가 여전히 열려 있다
# 실패해야: IPv6 ::/0 규칙이 남아 있어요
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=web-sg --query 'SecurityGroups[0].GroupId' --output text)
aws ec2 revoke-security-group-ingress --group-id "$SG" --protocol tcp --port 22 --cidr 0.0.0.0/0 > /dev/null
aws ec2 revoke-security-group-ingress --group-id "$SG" --protocol tcp --port 3306 --cidr 0.0.0.0/0 > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG" --protocol tcp --port 22 --cidr "$(cat ~/office-ip.txt)/32" > /dev/null
