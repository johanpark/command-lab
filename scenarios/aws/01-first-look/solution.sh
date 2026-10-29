aws ec2 describe-instances --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].InstanceId' --output text | wc -w > ~/running.txt
aws ec2 describe-instances --filters Name=tag:Name,Values=payment-api \
  --query 'Reservations[].Instances[].InstanceId' --output text > ~/answer.txt
aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' > ~/buckets.txt
