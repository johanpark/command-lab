F="Volumes[?!(Tags[?Key=='Keep' && Value=='true'])]"
aws ec2 describe-volumes --filters Name=status,Values=available --query "sum($F.Size)" --output text > ~/freed.txt
for v in $(aws ec2 describe-volumes --filters Name=status,Values=available --query "$F.VolumeId" --output text); do
  aws ec2 delete-volume --volume-id "$v"
done
