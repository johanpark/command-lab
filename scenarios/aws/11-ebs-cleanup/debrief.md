# 해설

```bash
F="Volumes[?!(Tags[?Key=='Keep' && Value=='true'])]"
aws ec2 describe-volumes --filters Name=status,Values=available --query "sum($F.Size)" --output text > ~/freed.txt
for v in $(aws ec2 describe-volumes --filters Name=status,Values=available --query "$F.VolumeId" --output text); do
  aws ec2 delete-volume --volume-id "$v"
done
```

> ⚠️ JMESPath 함정: `` Value==`true` `` 처럼 **백틱**으로 쓰면 문자열 `"true"` 가 아니라 **불리언 true** 라서 아무 태그와도 같지 않아요. 그 결과 보존 태그가 무시되고 전부 지워져요. 태그 값은 항상 문자열이니 `'true'` (작은따옴표) 로 비교하세요.

## 남은 볼륨이 생기는 이유
- 인스턴스를 만들 때 추가 디스크의 **"종료 시 삭제(DeleteOnTermination)"** 가 꺼져 있으면, 서버를 지워도 디스크가 남아요.
- 루트 디스크는 기본으로 같이 지워지지만, 추가로 붙인 데이터 디스크는 기본이 **남김**이에요.

## 지우기 전에 생각할 것
- 혹시 필요한 데이터가 있을까 싶으면 **스냅샷**을 먼저: `aws ec2 create-snapshot --volume-id vol-... --description "삭제 전 백업"`. 스냅샷은 볼륨보다 훨씬 싸요 (바뀐 블록만 저장).
- 이번처럼 **보존 태그** 규칙을 팀에서 정해 두면, 정리 스크립트가 실수로 중요한 디스크를 지우지 않아요.

## 비용 정리 단골 목록
| 대상 | 찾는 법 |
|---|---|
| 붙지 않은 EBS 볼륨 | `describe-volumes --filters Name=status,Values=available` |
| 연결 안 된 Elastic IP (시간당 요금) | `describe-addresses --query "Addresses[?AssociationId==null]"` |
| 오래된 스냅샷 | `describe-snapshots --owner-ids self` + 날짜 |
| 꺼 둔 채 방치된 인스턴스 | stop 상태여도 EBS 요금은 나가요 |

AWS **Trusted Advisor**, **Cost Explorer**, **Compute Optimizer** 가 이런 낭비를 찾아 줘요.
