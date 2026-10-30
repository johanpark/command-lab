LT=$(aws ec2 describe-launch-template-versions --launch-template-name web-lt --query 'LaunchTemplateVersions[].LaunchTemplateData.ImageId' --output text)
KEEP=$(aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' --query 'sort_by(Images,&Name)[-3:].ImageId' --output text)
aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' \
  --query 'Images[].[ImageId,BlockDeviceMappings[0].Ebs.SnapshotId]' --output text |
while read -r ami snap; do
  [[ " $(echo $KEEP $LT) " == *" $ami "* ]] && continue   # --output text 는 탭으로 구분돼서 공백으로 펴 준다
  aws ec2 deregister-image --image-id "$ami"
  aws ec2 delete-snapshot --snapshot-id "$snap"
done
