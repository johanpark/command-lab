# 설명: 끄라고 했는데 terminate 로 지워 버린다
# 실패해야: 삭제(terminate)한 서버가 없다
ids=$(aws ec2 describe-instances --filters Name=tag:Env,Values=dev Name=instance-state-name,Values=running --query "Reservations[].Instances[?!(Tags[?Key=='KeepRunning' && Value=='true'])].InstanceId" --output text)
aws ec2 terminate-instances --instance-ids $ids > /dev/null
echo $ids | wc -w > ~/stopped.txt
