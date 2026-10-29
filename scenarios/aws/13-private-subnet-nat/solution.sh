VPC=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
NAT=$(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values="$VPC" Name=state,Values=available --query 'NatGateways[0].NatGatewayId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$VPC" Name=tag:Name,Values=private-rt --query 'RouteTables[0].RouteTableId' --output text)
aws ec2 create-route --route-table-id "$RT" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$NAT" >/dev/null
SN=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC" Name=tag:Name,Values=app-c --query 'Subnets[0].SubnetId' --output text)
aws ec2 associate-route-table --route-table-id "$RT" --subnet-id "$SN" >/dev/null
