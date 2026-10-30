#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
V=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
sg() { aws ec2 create-security-group --group-name "$1" --description "$2" --vpc-id "$V" --query GroupId --output text; }
ALB=$(sg alb-sg "로드 밸런서"); APP=$(sg app-sg "앱 서버"); DB=$(sg db-sg "PostgreSQL"); CACHE=$(sg cache-sg "Redis"); BAS=$(sg bastion-sg "관리용 점프 서버")
allow() { aws ec2 authorize-security-group-ingress --group-id "$1" --ip-permissions "$2" >/dev/null; }
allow "$ALB" 'IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=0.0.0.0/0}]'
allow "$ALB" 'IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=0.0.0.0/0}]'
allow "$APP" "IpProtocol=tcp,FromPort=8080,ToPort=8080,UserIdGroupPairs=[{GroupId=$ALB}]"
allow "$BAS" 'IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=203.0.113.0/24,Description=office}]'
allow "$DB" 'IpProtocol=tcp,FromPort=5432,ToPort=5432,IpRanges=[{CidrIp=0.0.0.0/0,Description=temp-debug}]'
allow "$DB" 'IpProtocol=tcp,FromPort=5432,ToPort=5432,IpRanges=[{CidrIp=172.31.0.0/16,Description=vpc-all}]'
allow "$CACHE" 'IpProtocol=tcp,FromPort=6379,ToPort=6379,IpRanges=[{CidrIp=0.0.0.0/0}]'
allow "$CACHE" "IpProtocol=tcp,FromPort=6379,ToPort=6379,UserIdGroupPairs=[{GroupId=$APP}]"
secret_set app "$APP"; secret_set bas "$BAS"; secret_set db "$DB"; secret_set cache "$CACHE"
for g in "$ALB" "$APP" "$BAS"; do aws ec2 describe-security-groups --group-ids "$g" --query 'SecurityGroups[0].IpPermissions' --output json | jq -cS .; done > $S/keep
mkdir -p "$H"
cat > "$H/security-review.md" <<'MD'
# 보안 점검 결과 (네트워크)

| 보안 그룹 | 지적 사항 | 조치 |
|---|---|---|
| db-sg | 5432 가 0.0.0.0/0 (인터넷 전체) 와 172.31.0.0/16 (VPC 전체) 에 열림 | **app-sg** 와 **bastion-sg** 에서만 5432 허용 |
| cache-sg | 6379 가 0.0.0.0/0 에 열림 (app-sg 허용은 이미 있음) | **app-sg** 에서만 6379 허용 |
| alb-sg, app-sg, bastion-sg | 이상 없음 | 그대로 |

원칙: 서버끼리의 통신은 IP 대역이 아니라 **보안 그룹을 출처로** 지정한다.
MD
give "$H/security-review.md"
