#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
VPC=$(secret_get vpc); NAT=$(secret_get nat); OLD=$(secret_get old); S=/opt/cmdlab/secret
name() { aws ec2 describe-subnets --subnet-ids "$1" --query "Subnets[0].Tags[?Key=='Name']|[0].Value" --output text 2>/dev/null; }
# 서브넷이 실제로 따르는 라우팅 테이블 (명시적 연결이 없으면 main)
effective_rt() {
  local r; r=$(aws ec2 describe-route-tables --filters Name=association.subnet-id,Values="$1" --query 'RouteTables[0].RouteTableId' --output text)
  [ "$r" = None ] || [ -z "$r" ] && r=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$VPC" Name=association.main,Values=true --query 'RouteTables[0].RouteTableId' --output text)
  echo "$r"
}
default_route() { # → nat-... / igw-... / 없음
  aws ec2 describe-route-tables --route-table-ids "$1" \
    --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0']|[0].[NatGatewayId,GatewayId]" --output text 2>/dev/null \
    | tr '\t' '\n' | grep -E '^(nat|igw)-' | head -1
}
while read -r s; do
  n=$(name "$s"); t=$(default_route "$(effective_rt "$s")")
  case "$t" in
    "$NAT") pass "$n 의 바깥 트래픽이 NAT 게이트웨이로 나간다" ;;
    igw-*) fail "$n 의 바깥 트래픽이 NAT 게이트웨이로 나간다 (IGW 로 직접 보내면 공인 IP 없는 서버는 못 나가고, 프라이빗 서브넷도 아니게 돼요)" ;;
    "$OLD") fail "$n 의 바깥 트래픽이 NAT 게이트웨이로 나간다 (그 NAT 는 이미 삭제된(deleted) 거예요)" ;;
    "") fail "$n 의 바깥 트래픽이 NAT 게이트웨이로 나간다 (0.0.0.0/0 경로가 없어요)" ;;
    *) fail "$n 의 바깥 트래픽이 NAT 게이트웨이로 나간다 (지금: $t)" ;;
  esac
done < $S/private
ok=1; while read -r s; do [ "$(default_route "$(effective_rt "$s")")" = "$(secret_get igw)" ] || ok=0; done < $S/public
[ $ok = 1 ] && pass "퍼블릭 서브넷은 그대로 인터넷 게이트웨이로 나간다" || fail "퍼블릭 서브넷은 그대로 인터넷 게이트웨이로 나간다 (퍼블릭 경로가 바뀌었어요)"
finish
