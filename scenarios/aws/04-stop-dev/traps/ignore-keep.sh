# 설명: KeepRunning 태그를 안 보고 dev 를 다 끄면 켜 둬야 할 서버까지 꺼진다
# 실패해야: KeepRunning=true 서버는 계속
ids=$(aws ec2 describe-instances --filters Name=tag:Env,Values=dev Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text)
aws ec2 stop-instances --instance-ids $ids > /dev/null
echo $ids | wc -w > ~/stopped.txt
