# 오래된 서버 이미지와 스냅샷 정리 (AMI 등록 해제)

배포할 때마다 서버 이미지(**AMI**)를 하나씩 만들어 왔더니, 쓰지도 않는 AMI 가 잔뜩 쌓였어요.
AMI 는 실제로는 **EBS 스냅샷**을 가리키는 목록이라, 스냅샷 저장 요금이 계속 나가요. 보관 규칙은 `~/ami-policy.md` 에 있어요.

## 목표
1. `web-YYYYMMDD` AMI 중 **날짜가 가장 최근인 3개**는 남기세요.
2. **시작 템플릿 `web-lt` 가 쓰는 AMI** 도 남기세요.
3. 나머지 web AMI 는 **등록 해제**하고, **딸린 스냅샷도 지우세요.**
4. 남기는 AMI 의 스냅샷과 `batch-*` 이미지는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-images --owners self --query "Images[].[ImageId,Name,BlockDeviceMappings[0].Ebs.SnapshotId]" --output table` | 내 AMI 와 스냅샷 |
| `aws ec2 describe-launch-template-versions --launch-template-name web-lt --query "LaunchTemplateVersions[].LaunchTemplateData.ImageId"` | 시작 템플릿이 쓰는 AMI |
| `aws ec2 deregister-image --image-id ami-...` | AMI 등록 해제 |
| `aws ec2 delete-snapshot --snapshot-id snap-...` | 스냅샷 삭제 |
| `aws ec2 describe-snapshots --owner-ids self --filters Name=tag:App,Values=web` | 내 스냅샷 (태그로 좁히기) |

> 💡 AMI 를 등록 해제해도 **스냅샷은 자동으로 지워지지 않아요.** 반대로 AMI 가 살아 있는 스냅샷은 지울 수 없어요.
