먼저 전체 모습을 표로:
```
aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key=='Name']|[0].Value]" --output table
```
`Tags` 는 목록이라서 Name 태그만 꺼내려면 이렇게 해요.
---
실행 중인 것만 세기: `aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text | wc -w`. 텍스트 출력은 ID 들이 **탭**으로 한 줄에 나올 수 있어서 `wc -l` 이 아니라 `wc -w` 로 세요.
---
payment-api: `aws ec2 describe-instances --filters Name=tag:Name,Values=payment-api --query 'Reservations[].Instances[].InstanceId' --output text > ~/answer.txt`
---
버킷: `aws s3 ls` 는 날짜와 이름이 같이 나와요. 이름만: `aws s3 ls | awk '{print $3}' > ~/buckets.txt` 또는 `aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' > ~/buckets.txt`
