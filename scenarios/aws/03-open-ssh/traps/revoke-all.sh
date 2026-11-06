# 설명: 규칙을 전부 지우면 웹(80·443)까지 막혀 손님이 못 들어온다
# 실패해야: 웹(80, 443) 은 그대로
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=web-sg --query 'SecurityGroups[0].GroupId' --output text)
aws ec2 revoke-security-group-ingress --group-id "$SG" --ip-permissions "$(aws ec2 describe-security-groups --group-ids "$SG" --query 'SecurityGroups[0].IpPermissions' --output json)" > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG" --protocol tcp --port 22 --cidr "$(cat ~/office-ip.txt)/32" > /dev/null
