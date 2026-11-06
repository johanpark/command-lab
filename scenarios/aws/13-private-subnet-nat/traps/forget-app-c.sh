# 설명: 경로만 넣고 app-c 서브넷을 라우팅 테이블에 연결하지 않으면 app-c 는 여전히 못 나간다
# 실패해야: app-c 의 바깥 트래픽
VPC=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
NAT=$(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values="$VPC" Name=state,Values=available --query 'NatGateways[0].NatGatewayId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$VPC" Name=tag:Name,Values=private-rt --query 'RouteTables[0].RouteTableId' --output text)
aws ec2 create-route --route-table-id "$RT" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$NAT" >/dev/null
