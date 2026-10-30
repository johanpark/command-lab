web AMI 를 이름(날짜)순으로: `aws ec2 describe-images --owners self --filters "Name=name,Values=web-*" --query "sort_by(Images,&Name)[].[Name,ImageId,BlockDeviceMappings[0].Ebs.SnapshotId]" --output table`
(만든 순서와 이름의 날짜가 달라요. **이름의 날짜**로 판단하세요)
---
시작 템플릿이 쓰는 AMI: `aws ec2 describe-launch-template-versions --launch-template-name web-lt --query "LaunchTemplateVersions[].LaunchTemplateData.ImageId" --output text`
→ 이건 최근 3개가 아니어도 남겨요.
---
지울 AMI 마다 **등록 해제 → 스냅샷 삭제** 순서로. (순서를 바꾸면 `InvalidSnapshot.InUse` 에러)
```
aws ec2 deregister-image --image-id ami-...
aws ec2 delete-snapshot --snapshot-id snap-...
```
스냅샷 ID 는 등록 해제 **전에** 적어 두세요. 해제 후엔 AMI 에서 찾을 수 없어요.
