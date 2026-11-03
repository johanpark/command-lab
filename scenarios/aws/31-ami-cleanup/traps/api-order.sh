# 설명: describe-images 결과 순서(정렬 안 함)로 '마지막 3개' 를 고르면 엉뚱한 AMI 가 남는다
# 실패해야: 남겨야 할 AMI
# 실패해야: 나머지 web AMI
# 실패해야: 남기는 AMI 의 스냅샷
LT=$(aws ec2 describe-launch-template-versions --launch-template-name web-lt --query 'LaunchTemplateVersions[].LaunchTemplateData.ImageId' --output text)
KEEP=$(aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' --query 'Images[-3:].ImageId' --output text)
aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' --query 'Images[].[ImageId,BlockDeviceMappings[0].Ebs.SnapshotId]' --output text | while read -r a s; do
  [[ " $(echo $KEEP $LT) " == *" $a "* ]] && continue; aws ec2 deregister-image --image-id $a; aws ec2 delete-snapshot --snapshot-id $s; done
