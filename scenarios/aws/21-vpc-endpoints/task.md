# NAT 요금 폭탄 줄이기 (VPC 게이트웨이 엔드포인트)

이번 달 청구서에서 **NAT 게이트웨이 데이터 처리 요금**이 서버 요금보다 2배 넘게 나왔어요. 분석 결과는 `~/cost-report.md` 에 있어요.

프라이빗 서브넷의 서버가 S3·DynamoDB 를 쓰면, 그 트래픽도 기본적으로 NAT 를 거쳐 나가서 **GB 당 요금**이 붙어요.
**게이트웨이 엔드포인트**를 만들면 S3·DynamoDB 로 가는 트래픽은 NAT 를 거치지 않고 AWS 내부로 바로 가요. 그리고 **무료**예요.

## 목표
1. **`shop-vpc`** 에 **S3** 게이트웨이 엔드포인트를 만드세요.
2. **`shop-vpc`** 에 **DynamoDB** 게이트웨이 엔드포인트를 만드세요.
3. 두 엔드포인트 모두 프라이빗 라우팅 테이블 **`private-rt-a` 와 `private-rt-c`** 에 연결하세요.
4. 외부 API 는 계속 NAT 로 나가야 하니, **기존 NAT 경로(0.0.0.0/0)는 그대로** 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-vpc-endpoints` | 지금 있는 엔드포인트 (어느 VPC 것인지 확인!) |
| `aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-...` | 라우팅 테이블 ID |
| `aws ec2 create-vpc-endpoint --vpc-id vpc-... --vpc-endpoint-type Gateway --service-name com.amazonaws.ap-northeast-2.s3 --route-table-ids rtb-a rtb-c` | 게이트웨이 엔드포인트 만들기 |
| `aws ec2 modify-vpc-endpoint --vpc-endpoint-id vpce-... --add-route-table-ids rtb-...` | 라우팅 테이블 추가 연결 |

> 서비스 이름은 `com.amazonaws.<리전>.<서비스>` 형식이에요. 이 실습의 리전은 `ap-northeast-2` (서울).
