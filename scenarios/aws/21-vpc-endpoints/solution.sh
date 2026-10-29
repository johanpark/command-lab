V=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values="$V" Name=tag:Name,Values=private-rt-a,private-rt-c \
  --query 'RouteTables[].RouteTableId' --output text)
for svc in s3 dynamodb; do
  aws ec2 create-vpc-endpoint --vpc-id "$V" --vpc-endpoint-type Gateway \
    --service-name "com.amazonaws.ap-northeast-2.$svc" --route-table-ids $RT >/dev/null
done
