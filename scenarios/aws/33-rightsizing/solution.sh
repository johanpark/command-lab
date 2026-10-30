declare -A NEXT=([m5.2xlarge]=m5.xlarge [m5.xlarge]=m5.large [c5.2xlarge]=c5.xlarge [c5.xlarge]=c5.large [t3.large]=t3.medium)
S=$(date -u -d '-7 day' +%FT%TZ); E=$(date -u +%FT%TZ)
aws ec2 describe-instances --filters Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[?!(Tags[?Key=='DoNotResize' && Value=='true'])][].[InstanceId,InstanceType]" --output text |
while read -r i t; do
  read -r avg mx < <(aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value="$i" --start-time "$S" --end-time "$E" --period 604800 \
    --statistics Average Maximum --query 'Datapoints[0].[Average,Maximum]' --output text)
  if awk -v a="$avg" -v m="$mx" 'BEGIN { exit !(a < 10 && m < 40) }' && [ -n "${NEXT[$t]}" ]; then
    aws ec2 stop-instances --instance-ids "$i" >/dev/null
    aws ec2 wait instance-stopped --instance-ids "$i"
    aws ec2 modify-instance-attribute --instance-id "$i" --instance-type "{\"Value\": \"${NEXT[$t]}\"}"
    aws ec2 start-instances --instance-ids "$i" >/dev/null
  fi
done
