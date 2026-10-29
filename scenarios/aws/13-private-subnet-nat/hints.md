VPC ID 부터: `aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text`
그다음 라우팅 테이블마다 **경로**와 **연결된 서브넷**을 봐요:
`aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-... --query "RouteTables[].{id:RouteTableId,name:Tags[?Key=='Name']|[0].Value,main:Associations[?Main]|[0].Main,subnets:Associations[].SubnetId,routes:Routes[].[DestinationCidrBlock,GatewayId,NatGatewayId]}"`
---
문제가 **두 가지**예요.
- `private-rt` 에 `0.0.0.0/0` 경로가 없어요.
- `app-c` 는 어느 라우팅 테이블에도 명시적으로 연결돼 있지 않아서 **main 라우팅 테이블**(로컬 경로뿐)을 따라가요.
---
NAT 게이트웨이는 두 개가 보이는데 하나는 **deleted** 예요: `aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=vpc-... --query "NatGateways[].[NatGatewayId,State,Tags[?Key=='Name']|[0].Value]" --output table`
(이 명령만 옵션 이름이 `--filter` 단수형이에요)
---
```
aws ec2 create-route --route-table-id <private-rt> --destination-cidr-block 0.0.0.0/0 --nat-gateway-id <available 인 NAT>
aws ec2 associate-route-table --route-table-id <private-rt> --subnet-id <app-c>
```
