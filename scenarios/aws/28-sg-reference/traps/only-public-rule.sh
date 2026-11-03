# 설명: 0.0.0.0/0 규칙만 지우고 사내 대역 규칙과 cache-sg 는 그대로 둔다
# 실패해야: 아직 IP 대역에 열림: 172.31
# 실패해야: cache-sg 는 app-sg 에서만
id() { aws ec2 describe-security-groups --filters Name=group-name,Values="$1" --query 'SecurityGroups[0].GroupId' --output text; }
DB=$(id db-sg); APP=$(id app-sg)
r=$(aws ec2 describe-security-group-rules --filters Name=group-id,Values=$DB --query "SecurityGroupRules[?CidrIpv4=='0.0.0.0/0'].SecurityGroupRuleId" --output text)
aws ec2 revoke-security-group-ingress --group-id $DB --security-group-rule-ids $r
aws ec2 authorize-security-group-ingress --group-id $DB --protocol tcp --port 5432 --source-group $APP
