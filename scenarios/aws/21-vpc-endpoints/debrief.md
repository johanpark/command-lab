# 해설

```bash
V=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=shop-vpc --query 'Vpcs[0].VpcId' --output text)
RT=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$V Name=tag:Name,Values=private-rt-a,private-rt-c \
  --query 'RouteTables[].RouteTableId' --output text)
for svc in s3 dynamodb; do
  aws ec2 create-vpc-endpoint --vpc-id $V --vpc-endpoint-type Gateway \
    --service-name com.amazonaws.ap-northeast-2.$svc --route-table-ids $RT
done
```

## 무엇이 바뀌나
엔드포인트를 연결하면 라우팅 테이블에 경로가 하나 더 생겨요:
```
10.x.0.0/16   → local
pl-xxxx (S3 의 IP 목록)  → vpce-...     ← 새로 생김. 더 구체적인 경로라 우선
0.0.0.0/0     → nat-...                ← 외부 API 는 여전히 NAT
```
라우팅은 **가장 구체적인 경로**가 이겨요. S3 주소는 `pl-...` 목록에 들어 있어서 NAT 대신 엔드포인트로 가요.
앱 코드나 설정은 하나도 안 바꿔도 돼요. 같은 S3 주소로 접속하는데 길만 바뀌어요.

## 게이트웨이 vs 인터페이스 엔드포인트
| | Gateway | Interface (PrivateLink) |
|---|---|---|
| 지원 서비스 | **S3, DynamoDB 둘 뿐** | 대부분의 AWS 서비스 (SQS, ECR, Secrets Manager…) |
| 방식 | 라우팅 테이블에 경로 추가 | 서브넷에 ENI(사설 IP) 생성 |
| 요금 | **무료** | 시간당 + GB 당 |

## 실무 팁
- 새 VPC 를 만들면 S3·DynamoDB 게이트웨이 엔드포인트는 **처음부터 만들어 두는 게** 거의 정답이에요. 비용이 없고 보안도 좋아져요.
- 엔드포인트에 **정책**을 붙여서 "우리 회사 버킷에만 접근 가능" 처럼 데이터 유출 경로를 막을 수도 있어요.
- ECR 이미지 pull, CloudWatch 로그 전송처럼 다른 서비스 트래픽이 크면 인터페이스 엔드포인트도 비교해 보세요 (NAT 데이터 요금보다 쌀 때가 많아요).
