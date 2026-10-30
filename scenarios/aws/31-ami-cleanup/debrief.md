# 해설

```bash
LT=$(aws ec2 describe-launch-template-versions --launch-template-name web-lt \
  --query 'LaunchTemplateVersions[].LaunchTemplateData.ImageId' --output text)
KEEP=$(aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' \
  --query 'sort_by(Images,&Name)[-3:].ImageId' --output text)       # 이름(날짜) 기준 최근 3개
aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' \
  --query 'Images[].[ImageId,BlockDeviceMappings[0].Ebs.SnapshotId]' --output text |
while read -r ami snap; do
  [[ " $(echo $KEEP $LT) " == *" $ami "* ]] && continue   # --output text 는 탭으로 구분돼서 공백으로 펴 준다
  aws ec2 deregister-image --image-id $ami
  aws ec2 delete-snapshot --snapshot-id $snap
done
```

## AMI 와 스냅샷의 관계
```
AMI (ami-...) ── "이 스냅샷들로 디스크를 만들어라" 라는 목록 (무료)
  └─ EBS 스냅샷 (snap-...) ── 실제 데이터 (GB 당 요금)
```
- **deregister-image** 는 목록만 지워요. 스냅샷은 그대로 남아서 요금이 계속 나가요. 이렇게 주인 없이 남은 스냅샷이 비용 점검 때 가장 많이 발견되는 낭비예요.
- 반대로 AMI 가 살아 있으면 스냅샷은 `InvalidSnapshot.InUse` 로 지워지지 않아요. 그래서 **해제 → 삭제** 순서.

## 왜 시작 템플릿이 쓰는 AMI 를 지키나
오토스케일링이 서버를 새로 띄울 때 시작 템플릿의 AMI 를 써요. 그 AMI 를 지우면 **새 서버가 하나도 안 떠요** (트래픽이 늘어도, 서버가 죽어도). 날짜만 보고 지우면 롤백 상태에서 사고가 나요.

## 실무 팁
- **EC2 이미지 빌더**나 **DLM(Data Lifecycle Manager)** 의 AMI 정책을 쓰면 "최근 N개만 보관 + 스냅샷 같이 삭제" 를 자동으로 해 줘요.
- 실수 대비로 **휴지통(Recycle Bin)** 규칙을 걸어 두면, 지운 스냅샷·AMI 를 정해진 기간 동안 되살릴 수 있어요.
