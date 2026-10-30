#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
V=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
SN=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$V" --query 'Subnets[0:2].SubnetId' --output text)
aws elbv2 create-load-balancer --name shop-alb --subnets $SN --query 'LoadBalancers[0].LoadBalancerArn' --output text > $S/alb
aws elbv2 create-load-balancer --name admin-alb --subnets $SN --query 'LoadBalancers[0].LoadBalancerArn' --output text > $S/admin
a=$(rand_int 10 250); b=$(rand_int 10 250); OFF=211.$(rand_int 100 250).$(rand_int 10 250).$(rand_int 10 250)
printf '%s\n' "45.$a.$b.17/32" "45.$a.$b.18/32" "185.$b.$a.0/24" "91.$a.12.$(rand_int 10 250)/32" | sort > $S/attack
secret_set office "$OFF"
R=$(rand_pick 100 200 300); secret_set rate "$R"
mkdir -p "$H"
{
  echo "# 로그인 공격 분석 (지난 1시간, POST /login 실패 수)"
  echo
  echo "| 출발지 | 실패 수 | 비고 |"
  echo "|---|---|---|"
  i=0; while read -r c; do i=$((i + 1)); echo "| $c | $((9000 - i * 1700)) | |"; done < $S/attack
  echo "| $OFF/32 | 412 | |"
  echo
  echo "※ 185.x.x.0/24 는 대역 전체가 공격에 쓰이고 있어서 대역째 막을 것"
  echo
  echo "## 조치"
  echo "1. 위 출발지를 IP 집합 **blocked-ips** 로 만들어 차단 — 단, **회사 사무실 IP 는 제외** (~/office.txt)"
  echo "2. IP 하나가 **5분에 $R 번** 넘게 요청하면 자동 차단 (속도 제한)"
  echo "3. 위 두 규칙을 담은 웹 ACL **shop-waf** (기본 동작: 허용) 를 **shop-alb** 에 연결"
  echo "   admin-alb 는 사내 전용이라 이번 대상 아님"
} > "$H/attack-report.md"
echo "회사 사무실 공인 IP (NAT): $OFF   ← QA 팀 자동 로그인 테스트 때문에 실패가 많음" > "$H/office.txt"
give "$H/attack-report.md" "$H/office.txt"
