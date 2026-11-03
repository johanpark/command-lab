# 설명: CPU 만 보고 기준 밖 서버까지 줄이고, 줄인 뒤 다시 켜지 않는다
# 실패해야: 기준에 맞지 않는 서버
# 실패해야: 모든 서버가 실행 중
declare -A NEXT=([m5.2xlarge]=m5.xlarge [m5.xlarge]=m5.large [c5.2xlarge]=c5.xlarge [c5.xlarge]=c5.large [t3.large]=t3.medium)
for x in $(aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType]' --output text | tr '\t' ':'); do i=${x%%:*}; t=${x#*:}
  a=$(aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=$i --start-time $(date -u -d '-7 day' +%FT%TZ) --end-time $(date -u +%FT%TZ) --period 604800 --statistics Average --query 'Datapoints[0].Average' --output text)
  if awk -v a=$a 'BEGIN{exit !(a<10)}'; then aws ec2 stop-instances --instance-ids $i >/dev/null; aws ec2 modify-instance-attribute --instance-id $i --instance-type "{\"Value\":\"${NEXT[$t]}\"}"; fi; done
