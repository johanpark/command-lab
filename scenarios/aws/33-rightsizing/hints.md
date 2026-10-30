한 서버의 7일 통계를 한 줄로 (기간을 7일 = 604800초 하나로 잡으면 값이 하나만 나와요):
```
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-... --start-time $(date -u -d '-7 day' +%FT%TZ) --end-time $(date -u +%FT%TZ) \
  --period 604800 --statistics Average Maximum --query 'Datapoints[0].[Average,Maximum]' --output text
```
---
서버가 7대라 반복문으로 표를 만들어 보세요:
`for i in $(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text); do echo "$i $(위 명령)"; done`
**평균만 보면 안 돼요.** 평균은 낮은데 최대가 90% 인 서버(밤에만 바쁜 배치)가 있어요.
---
DoNotResize 태그 확인: `aws ec2 describe-instances --filters Name=tag:DoNotResize,Values=true --query 'Reservations[].Instances[].InstanceId'`
---
서버 하나 바꾸기:
```
aws ec2 stop-instances --instance-ids i-... && aws ec2 wait instance-stopped --instance-ids i-...
aws ec2 modify-instance-attribute --instance-id i-... --instance-type '{"Value": "m5.large"}'
aws ec2 start-instances --instance-ids i-...
```
