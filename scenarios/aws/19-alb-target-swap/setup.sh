#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami); S=/opt/cmdlab/secret
VPC=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
SN=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC" --query 'Subnets[0:2].SubnetId' --output text)
LB=$(aws elbv2 create-load-balancer --name shop-alb --subnets $SN --query 'LoadBalancers[0].LoadBalancerArn' --output text)
TG=$(aws elbv2 create-target-group --name web-tg --protocol HTTP --port 80 --vpc-id "$VPC" --health-check-path / \
  --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 create-listener --load-balancer-arn "$LB" --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn="$TG" >/dev/null
inst() { aws ec2 run-instances --image-id "$ami" --instance-type t3.small \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1},{Key=Version,Value=$2}]" --query 'Instances[0].InstanceId' --output text; }
: > $S/v1; : > $S/v2
for n in web-v1-a web-v1-b; do i=$(inst $n v1); echo "$i" >> $S/v1; aws elbv2 register-targets --target-group-arn "$TG" --targets Id="$i"; done
for n in web-v2-a web-v2-b; do inst $n v2 >> $S/v2; done
bad=$(inst web-v2-c v2); aws ec2 stop-instances --instance-ids "$bad" >/dev/null
secret_set tg "$TG"; secret_set lb "$LB"
P=$(rand_pick 8080 3000 8000); secret_set port "$P"
HP=$(rand_pick /healthz /health /api/health); secret_set hp "$HP"
mkdir -p "$H"
cat > "$H/deploy.md" <<MD
# v2 배포 체크리스트

- 새 서버: \`Version=v2\` 태그가 붙은 EC2 중 **실행 중인 것** (web-v2-c 는 부팅 중 문제가 있어 꺼 둠, 제외)
- v2 앱은 **$P 포트**에서 동작함 (v1 은 80)
- v2 앱의 헬스 체크 주소는 **$HP** (v1 의 / 는 v2 에서 404)
- 순서
  1. 대상 그룹 \`web-tg\` 에 v2 서버를 등록 (포트 주의!)
  2. 헬스 체크 경로를 v2 에 맞게 변경
  3. v1 서버를 대상 그룹에서 빼기
- v1 서버는 문제 생기면 되돌려야 하니 **하루 동안 끄거나 지우지 말 것**
MD
give "$H/deploy.md"
