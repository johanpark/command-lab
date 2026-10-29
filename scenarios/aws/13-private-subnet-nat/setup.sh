#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami); S=/opt/cmdlab/secret
tag() { echo "ResourceType=$1,Tags=[{Key=Name,Value=$2}]"; }
o=$(rand_int 10 90)
VPC=$(aws ec2 create-vpc --cidr-block 10.$o.0.0/16 --tag-specifications "$(tag vpc shop-vpc)" --query Vpc.VpcId --output text)
sub() { aws ec2 create-subnet --vpc-id "$VPC" --cidr-block "10.$o.$1.0/24" --availability-zone "ap-northeast-2$2" \
  --tag-specifications "$(tag subnet "$3")" --query Subnet.SubnetId --output text; }
PA=$(sub 0 a public-a); PC=$(sub 1 c public-c); AA=$(sub 10 a app-a); AC=$(sub 11 c app-c)
IGW=$(aws ec2 create-internet-gateway --tag-specifications "$(tag internet-gateway shop-igw)" --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC"
rt() { aws ec2 create-route-table --vpc-id "$VPC" --tag-specifications "$(tag route-table "$1")" --query RouteTable.RouteTableId --output text; }
PUB=$(rt public-rt)
aws ec2 create-route --route-table-id "$PUB" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW" >/dev/null
for s in "$PA" "$PC"; do aws ec2 associate-route-table --route-table-id "$PUB" --subnet-id "$s" >/dev/null; done
# 예전에 쓰다 지운 NAT (deleted) 와 지금 쓰는 NAT
e1=$(aws ec2 allocate-address --query AllocationId --output text)
OLD=$(aws ec2 create-nat-gateway --subnet-id "$PC" --allocation-id "$e1" --tag-specifications "$(tag natgateway shop-nat-old)" --query NatGateway.NatGatewayId --output text)
aws ec2 delete-nat-gateway --nat-gateway-id "$OLD" >/dev/null
e2=$(aws ec2 allocate-address --query AllocationId --output text)
NAT=$(aws ec2 create-nat-gateway --subnet-id "$PA" --allocation-id "$e2" --tag-specifications "$(tag natgateway shop-nat)" --query NatGateway.NatGatewayId --output text)
# 프라이빗 라우팅 테이블: 누가 NAT 경로를 지워 버렸고, app-c 는 연결도 안 돼 있음 (main 을 따라감)
PRV=$(rt private-rt)
aws ec2 associate-route-table --route-table-id "$PRV" --subnet-id "$AA" >/dev/null
for n in app-1:$AA app-2:$AC; do
  aws ec2 run-instances --image-id "$ami" --instance-type t3.small --subnet-id "${n#*:}" \
    --tag-specifications "$(tag instance "${n%%:*}")" >/dev/null
done
secret_set vpc "$VPC"; secret_set nat "$NAT"; secret_set old "$OLD"; secret_set igw "$IGW"
printf '%s\n' "$AA" "$AC" > $S/private; printf '%s\n' "$PA" "$PC" > $S/public
