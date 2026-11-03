# 해설

```bash
# 1) 아무 데도 안 붙은 주소 (Keep=true 제외)
aws ec2 describe-addresses --output json \
  | jq -r '.Addresses[] | select(.AssociationId == null)
           | select(any(.Tags[]?; .Key == "Keep" and .Value == "true") | not) | .AllocationId' \
  | while read -r a; do aws ec2 release-address --allocation-id "$a"; done

# 2) old-batch: 떼고 → 반납
OB=$(aws ec2 describe-instances --filters Name=tag:Name,Values=old-batch \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)
read -r AS AL < <(aws ec2 describe-addresses --filters Name=instance-id,Values=$OB \
  --query 'Addresses[0].[AssociationId,AllocationId]' --output text)
aws ec2 disassociate-address --association-id $AS
aws ec2 release-address --allocation-id $AL
```

## "연결" 은 서버에만 하는 게 아니에요
| 붙은 곳 | `InstanceId` | `NetworkInterfaceId` | `AssociationId` |
|---|---|---|---|
| EC2 서버 | 있음 | 있음 | 있음 |
| NAT 게이트웨이, 로드 밸런서 등 | **없음** | 있음 | 있음 |
| 아무 데도 | 없음 | 없음 | **없음** |

`InstanceId` 가 없는 걸 골라 지우면 NAT 게이트웨이 주소까지 걸려요. 실제 AWS 는 연결된 주소의 반납을 `InvalidIPAddress.InUse` 로 막아 주지만, 먼저 `disassociate` 해 버리면 막을 방법이 없어요 → 프라이빗 서버 전체가 인터넷에 못 나가요. 기준은 항상 **`AssociationId`**.

## 꺼진 서버의 주소도 요금이 나가요
서버를 멈춰도 주소는 붙어 있고, 퍼블릭 IPv4 요금(시간당 $0.005, 월 약 $3.6)은 계속 나가요. "꺼 뒀으니 공짜" 가 아니에요.

## 반납은 되돌릴 수 없어요
같은 IP 를 다시 받을 방법이 없어요. 그래서 파트너 방화벽·고객 화이트리스트에 등록된 주소는 `Keep=true` 같은 태그로 표시해 두고, 정리 스크립트가 태그를 보도록 하는 게 안전해요.

## 실무 팁
- **AWS Config** 의 `eip-attached` 규칙이 연결 안 된 주소를 계속 찾아 줘요.
- 주소가 꼭 필요한 게 아니라면, 서버 앞에 로드 밸런서를 두고 DNS 이름으로 접속하게 하는 편이 고정 IP 를 덜 써요.
