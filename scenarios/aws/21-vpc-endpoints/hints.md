엔드포인트가 이미 하나 보여도 **어느 VPC 것인지** 확인하세요:
`aws ec2 describe-vpc-endpoints --query "VpcEndpoints[].[VpcId,ServiceName,VpcEndpointType,RouteTableIds]" --output json`
`aws ec2 describe-vpcs --query "Vpcs[].[VpcId,Tags[?Key=='Name']|[0].Value]" --output table`
---
프라이빗 라우팅 테이블 두 개의 ID 를 한 번에:
`aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-... Name=tag:Name,Values=private-rt-a,private-rt-c --query "RouteTables[].RouteTableId" --output text`
---
`--route-table-ids` 에는 여러 개를 공백으로 줄 수 있어요. 서비스마다 하나씩, 두 번 만들면 돼요:
`aws ec2 create-vpc-endpoint --vpc-id vpc-... --vpc-endpoint-type Gateway --service-name com.amazonaws.ap-northeast-2.s3 --route-table-ids rtb-aaa rtb-ccc`
(`dynamodb` 도 같은 방식. **Interface** 타입은 유료라 이번 목적과 달라요)
