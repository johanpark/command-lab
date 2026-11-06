# 설명: 상태를 거르지 않으면 꺼진 인스턴스까지 센다
# 실패해야: 실행 중인 인스턴스 수
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text | wc -w > ~/running.txt
aws ec2 describe-instances --filters Name=tag:Name,Values=payment-api --query 'Reservations[].Instances[].InstanceId' --output text > ~/answer.txt
aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' > ~/buckets.txt
