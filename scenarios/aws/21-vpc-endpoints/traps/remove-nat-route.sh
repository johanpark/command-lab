# 설명: NAT 요금을 줄이겠다고 0.0.0.0/0 NAT 경로까지 지우면 결제·메일 같은 외부 API 가 끊긴다
# 실패해야: 외부 API 용 NAT 경로
# 모범 풀이 먼저
V=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
for rt in $(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$V" Name=tag:Name,Values=private-rt-a,private-rt-c --query 'RouteTables[].RouteTableId' --output text); do
  aws ec2 delete-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0
done
