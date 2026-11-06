# 설명: aws s3 ls 출력을 그대로 저장해도 버킷 이름은 인정된다
# 통과해야
aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'length(Reservations[].Instances[])' --output text > ~/running.txt
aws ec2 describe-instances --filters Name=tag:Name,Values=payment-api --query 'Reservations[0].Instances[0].InstanceId' --output text > ~/answer.txt
aws s3 ls > ~/buckets.txt
