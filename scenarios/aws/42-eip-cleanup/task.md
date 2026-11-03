# 안 쓰는 고정 IP 요금 줄이기 (Elastic IP 정리)

비용 점검에서 "쓰지도 않는 고정 IP(Elastic IP) 요금이 매달 나간다" 는 지적을 받았어요. 정리 기준은 `~/eip-memo.md` 에 있어요.

**Elastic IP** 는 서버가 꺼졌다 켜져도 바뀌지 않는 고정 공인 IP 예요. 한번 **반납(release)하면 같은 IP 는 다시 받을 수 없어요.** 그래서 무엇을 지킬지 먼저 정확히 골라야 해요.

## 목표
1. **아무 데도 연결되지 않은** Elastic IP 를 반납하세요. 단, `Keep=true` 태그가 붙은 예약 주소는 남겨 두세요.
2. 폐기 예정인 **`old-batch`** 서버에 붙은 주소를 **떼어서 반납**하세요. 서버 자체는 그대로 둬요.
3. 운영 서버(`web-1`, `web-2`)와 **NAT 게이트웨이**의 주소는 그대로 둬요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-addresses --output table` | 내 Elastic IP 전체 |
| `aws ec2 describe-addresses --query 'Addresses[].[AllocationId,PublicIp,AssociationId,InstanceId,NetworkInterfaceId]' --output table` | 주소마다 연결 상태 |
| `aws ec2 describe-addresses --filters Name=instance-id,Values=i-...` | 특정 서버에 붙은 주소 |
| `aws ec2 disassociate-address --association-id eipassoc-...` | 서버에서 주소 떼기 |
| `aws ec2 release-address --allocation-id eipalloc-...` | 주소 반납 (되돌릴 수 없음!) |

> 💡 **연결 여부는 `AssociationId` 로 보세요.** 주소는 서버(`InstanceId`)뿐 아니라 NAT 게이트웨이·로드 밸런서 같은 **네트워크 인터페이스**에도 붙어요.
