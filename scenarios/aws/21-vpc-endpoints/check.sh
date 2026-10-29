#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
V=$(secret_get vpc); S=/opt/cmdlab/secret
EP=$(aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values="$V" --output json 2>/dev/null)
read -r RA NA < <(sed -n 1p $S/private); read -r RC NC < <(sed -n 2p $S/private)
for svc in s3 dynamodb; do
  name=com.amazonaws.ap-northeast-2.$svc
  rts=$(jq -r --arg n "$name" '[.VpcEndpoints[] | select(.ServiceName == $n and ((.VpcEndpointType // "Gateway") | IN("Gateway", "None")) and .State != "deleted") | .RouteTableIds[]?] | unique | join(" ")' <<< "$EP")
  label=$([ $svc = s3 ] && echo S3 || echo DynamoDB)
  if [ -z "$(jq -r --arg n "$name" '.VpcEndpoints[] | select(.ServiceName == $n) | .VpcEndpointId' <<< "$EP")" ]; then
    fail "shop-vpc 에 $label 게이트웨이 엔드포인트가 두 프라이빗 라우팅 테이블에 연결돼 있다 (shop-vpc 에 $label 엔드포인트가 없어요)"
  elif [[ " $rts " == *" $RA "* && " $rts " == *" $RC "* ]]; then
    pass "shop-vpc 에 $label 게이트웨이 엔드포인트가 두 프라이빗 라우팅 테이블에 연결돼 있다"
  elif [ -z "$rts" ]; then
    fail "shop-vpc 에 $label 게이트웨이 엔드포인트가 두 프라이빗 라우팅 테이블에 연결돼 있다 (Gateway 타입이 아니거나 라우팅 테이블이 연결되지 않았어요)"
  else
    miss=""; [[ " $rts " == *" $RA "* ]] || miss+="private-rt-a "; [[ " $rts " == *" $RC "* ]] || miss+="private-rt-c "
    fail "shop-vpc 에 $label 게이트웨이 엔드포인트가 두 프라이빗 라우팅 테이블에 연결돼 있다 (빠짐: ${miss% })"
  fi
done
ok=1; for p in "$RA $NA" "$RC $NC"; do
  set -- $p
  t=$(aws ec2 describe-route-tables --route-table-ids "$1" --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'].NatGatewayId" --output text)
  [ "$t" = "$2" ] || ok=0
done
[ $ok = 1 ] && pass "외부 API 용 NAT 경로(0.0.0.0/0)는 그대로다" || fail "외부 API 용 NAT 경로(0.0.0.0/0)는 그대로다 (결제·메일이 끊겨요!)"
finish
