# 해설

```bash
VPC=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
NAT=$(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC Name=state,Values=available --query 'NatGateways[0].NatGatewayId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC Name=tag:Name,Values=private-rt --query 'RouteTables[0].RouteTableId' --output text)
aws ec2 create-route --route-table-id $RT --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT
SN=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC Name=tag:Name,Values=app-c --query 'Subnets[0].SubnetId' --output text)
aws ec2 associate-route-table --route-table-id $RT --subnet-id $SN
```

## 퍼블릭 / 프라이빗 서브넷의 차이는 "라우팅 테이블" 뿐
| | 0.0.0.0/0 가 가는 곳 | 바깥에서 들어오기 | 바깥으로 나가기 |
|---|---|---|---|
| 퍼블릭 서브넷 | **IGW** (인터넷 게이트웨이) | 공인 IP 가 있으면 가능 | 가능 |
| 프라이빗 서브넷 | **NAT 게이트웨이** (퍼블릭 서브넷에 있음) | 불가능 | NAT 의 공인 IP 로 가능 |

- 프라이빗 서브넷에 IGW 경로를 넣으면 이름만 프라이빗이지 사실상 퍼블릭이 되고, 공인 IP 가 없는 서버는 그래도 못 나가요.
- **NAT 게이트웨이 자체는 퍼블릭 서브넷에** 있어야 해요 (NAT 도 IGW 를 통해 나가니까).

## 서브넷이 따르는 라우팅 테이블 찾기
1. `association.subnet-id` 로 명시적으로 연결된 테이블이 있으면 그것
2. 없으면 VPC 의 **main 라우팅 테이블**

main 에 NAT 경로를 넣어도 이번 문제는 풀리지만, 그러면 앞으로 만드는 **모든 새 서브넷**이 자동으로 NAT 를 쓰게 돼요. 서브넷마다 명시적으로 연결하는 편이 의도가 분명해요.

## 실무 팁
- NAT 게이트웨이는 **시간당 요금 + 처리한 데이터량 요금**이 있어요. S3·DynamoDB 로 가는 트래픽은 **VPC 게이트웨이 엔드포인트**(무료)로 빼면 NAT 비용이 크게 줄어요.
- 가용 영역(AZ) 장애에 대비하려면 AZ 마다 NAT 를 하나씩 두고, 같은 AZ 의 프라이빗 서브넷이 그 NAT 를 쓰게 해요.
- 지운 NAT 를 가리키는 경로는 상태가 **blackhole** 이 돼요: `--query "RouteTables[].Routes[?State=='blackhole']"` 로 찾을 수 있어요.
