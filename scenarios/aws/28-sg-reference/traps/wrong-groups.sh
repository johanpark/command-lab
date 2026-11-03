# 설명: 6379 를 db-sg 에 열고, cache-sg 는 그대로 두고, alb-sg 에 SSH 를 연다
# 실패해야: 필요 없는 규칙
# 실패해야: cache-sg 는 app-sg 에서만
# 실패해야: 그대로다
id() { aws ec2 describe-security-groups --filters Name=group-name,Values="$1" --query 'SecurityGroups[0].GroupId' --output text; }
DB=$(id db-sg); APP=$(id app-sg); BAS=$(id bastion-sg); ALB=$(id alb-sg)
r=$(aws ec2 describe-security-group-rules --filters Name=group-id,Values=$DB --query "SecurityGroupRules[?!IsEgress].SecurityGroupRuleId" --output text)
aws ec2 revoke-security-group-ingress --group-id $DB --security-group-rule-ids $r
for s in $APP $BAS; do aws ec2 authorize-security-group-ingress --group-id $DB --protocol tcp --port 5432 --source-group $s; done
aws ec2 authorize-security-group-ingress --group-id $DB --protocol tcp --port 6379 --source-group $APP
aws ec2 authorize-security-group-ingress --group-id $ALB --protocol tcp --port 22 --cidr 0.0.0.0/0
