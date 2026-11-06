# 설명: 라우팅 테이블 하나에만 연결하면 다른 AZ 의 서버는 계속 NAT 로 나간다
# 실패해야: 빠짐: private-rt-c
V=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$V" Name=tag:Name,Values=private-rt-a --query 'RouteTables[0].RouteTableId' --output text)
for svc in s3 dynamodb; do
  aws ec2 create-vpc-endpoint --vpc-id "$V" --vpc-endpoint-type Gateway --service-name "com.amazonaws.ap-northeast-2.$svc" --route-table-ids $RT >/dev/null
done
