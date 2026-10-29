#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
tag() { echo "ResourceType=$1,Tags=[{Key=Name,Value=$2}]"; }
# 예전 VPC (여기엔 이미 S3 엔드포인트가 있음 → 헷갈리기 쉬움)
LV=$(aws ec2 create-vpc --cidr-block 172.20.0.0/16 --tag-specifications "$(tag vpc legacy-vpc)" --query Vpc.VpcId --output text)
LRT=$(aws ec2 create-route-table --vpc-id "$LV" --tag-specifications "$(tag route-table legacy-private-rt)" --query RouteTable.RouteTableId --output text)
aws ec2 create-vpc-endpoint --vpc-id "$LV" --service-name com.amazonaws.ap-northeast-2.s3 --vpc-endpoint-type Gateway --route-table-ids "$LRT" \
  --query VpcEndpoint.VpcEndpointId --output text > $S/legacy-ep
# 운영 VPC
o=$(rand_int 10 90)
V=$(aws ec2 create-vpc --cidr-block 10.$o.0.0/16 --tag-specifications "$(tag vpc shop-vpc)" --query Vpc.VpcId --output text)
sub() { aws ec2 create-subnet --vpc-id "$V" --cidr-block "10.$o.$1.0/24" --availability-zone "ap-northeast-2$2" --tag-specifications "$(tag subnet "$3")" --query Subnet.SubnetId --output text; }
PA=$(sub 0 a public-a); PC=$(sub 1 c public-c); AA=$(sub 10 a app-a); AC=$(sub 11 c app-c)
IGW=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$V"
rt() { aws ec2 create-route-table --vpc-id "$V" --tag-specifications "$(tag route-table "$1")" --query RouteTable.RouteTableId --output text; }
PUB=$(rt public-rt); aws ec2 create-route --route-table-id "$PUB" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW" >/dev/null
for s in "$PA" "$PC"; do aws ec2 associate-route-table --route-table-id "$PUB" --subnet-id "$s" >/dev/null; done
: > $S/private
for z in a c; do
  e=$(aws ec2 allocate-address --query AllocationId --output text)
  pub=$PA; [ $z = c ] && pub=$PC
  nat=$(aws ec2 create-nat-gateway --subnet-id "$pub" --allocation-id "$e" --tag-specifications "$(tag natgateway "nat-$z")" --query NatGateway.NatGatewayId --output text)
  r=$(rt "private-rt-$z"); aws ec2 create-route --route-table-id "$r" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$nat" >/dev/null
  s=$AA; [ $z = c ] && s=$AC
  aws ec2 associate-route-table --route-table-id "$r" --subnet-id "$s" >/dev/null
  echo "$r $nat" >> $S/private
done
secret_set vpc "$V"
mkdir -p "$H"
cat > "$H/cost-report.md" <<MD
# 10월 AWS 비용 분석 (shop-vpc)

| 항목 | 금액 |
|---|---|
| EC2 (앱 서버 6대) | \$ 412 |
| **NAT 게이트웨이 데이터 처리** | **\$ 1,038** |
| NAT 게이트웨이 시간당 요금 (2개) | \$ 66 |

NAT 를 지나간 트래픽의 목적지 (VPC Flow Logs 분석)
- S3 (이미지 업로드, 로그 백업) ............ $(rand_int 58 66)%
- DynamoDB (장바구니, 세션) ................ $(rand_int 22 28)%
- 외부 API (결제 PG, 메일 발송) ............ 나머지

→ S3 와 DynamoDB 는 **게이트웨이 엔드포인트(무료)** 로 빼자.
  프라이빗 서브넷의 라우팅 테이블(private-rt-a, private-rt-c) 에 연결.
  외부 API 는 계속 NAT 로 나가야 함!
MD
give "$H/cost-report.md"
