# 설명: 프라이빗 경로를 인터넷 게이트웨이로 보내면 공인 IP 없는 서버는 여전히 못 나간다
# 실패해야: IGW 로 직접 보내면
VPC=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
IGW=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values="$VPC" --query 'InternetGateways[0].InternetGatewayId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$VPC" Name=tag:Name,Values=private-rt --query 'RouteTables[0].RouteTableId' --output text)
aws ec2 create-route --route-table-id "$RT" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW" >/dev/null
SN=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC" Name=tag:Name,Values=app-c --query 'Subnets[0].SubnetId' --output text)
aws ec2 associate-route-table --route-table-id "$RT" --subnet-id "$SN" >/dev/null
