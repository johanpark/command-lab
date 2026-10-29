대상 그룹 ARN: `aws elbv2 describe-target-groups --names web-tg --query 'TargetGroups[0].[TargetGroupArn,Port,HealthCheckPath]' --output text`
지금 등록된 서버: `aws elbv2 describe-target-health --target-group-arn ARN --query "TargetHealthDescriptions[].[Target.Id,Target.Port,TargetHealth.State]" --output table`
---
v2 서버 중 실행 중인 것만:
`aws ec2 describe-instances --filters Name=tag:Version,Values=v2 Name=instance-state-name,Values=running --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name']|[0].Value]" --output table`
(꺼진 서버는 등록하려 하면 `InvalidTarget` 에러가 나요)
---
대상 그룹의 포트(80)와 v2 앱 포트가 달라요. 등록할 때 **서버마다 포트를 지정**할 수 있어요:
`--targets Id=i-aaa,Port=8080 Id=i-bbb,Port=8080`
---
헬스 체크: `aws elbv2 modify-target-group --target-group-arn ARN --health-check-path /경로`
v1 빼기: `aws elbv2 deregister-targets --target-group-arn ARN --targets Id=i-... Id=i-...` (서버는 stop/terminate 하지 마세요)
