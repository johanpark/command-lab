켜진 dev 서버와 태그를 표로 보세요:
```
aws ec2 describe-instances --filters Name=tag:Env,Values=dev Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[].[InstanceId, Tags[?Key=='Name']|[0].Value, Tags[?Key=='KeepRunning']|[0].Value]" --output table
```
`--filters` 는 "이 태그가 **있는**" 것만 고를 수 있고, "이 태그가 **없는**" 것은 고를 수 없어요.
---
"없는 것" 은 `--query` 로 걸러요. KeepRunning 이 true 가 아닌 것만:
```
--query "Reservations[].Instances[?!(Tags[?Key=='KeepRunning' && Value=='true'])].InstanceId" --output text
```
---
그 결과를 변수에 담아 끄기: `ids=$(위 명령)` → `echo $ids` 로 확인 → `aws ec2 stop-instances --instance-ids $ids`. 개수: `echo $ids | wc -w > ~/stopped.txt`
---
마지막에 `aws ec2 describe-instances --query "Reservations[].Instances[].[Tags[?Key=='Env']|[0].Value, State.Name]" --output text | sort | uniq -c` 로 환경별 상태를 확인하세요.
