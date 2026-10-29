ids=$(aws ec2 describe-instances \
  --filters Name=tag:Env,Values=dev Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[?!(Tags[?Key=='KeepRunning' && Value=='true'])].InstanceId" \
  --output text)
aws ec2 stop-instances --instance-ids $ids > /dev/null
echo $ids | wc -w > ~/stopped.txt
