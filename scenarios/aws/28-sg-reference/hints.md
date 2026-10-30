규칙 하나하나를 ID 와 함께 보면 편해요:
`aws ec2 describe-security-group-rules --filters Name=group-id,Values=<db-sg ID> --query "SecurityGroupRules[?!IsEgress].[SecurityGroupRuleId,FromPort,CidrIpv4,ReferencedGroupInfo.GroupId,Description]" --output table`
---
IP 대역 규칙 지우기: `aws ec2 revoke-security-group-ingress --group-id <db-sg> --security-group-rule-ids sgr-aaa sgr-bbb`
---
보안 그룹을 출처로 허용:
`aws ec2 authorize-security-group-ingress --group-id <db-sg> --protocol tcp --port 5432 --source-group <app-sg ID>`
bastion-sg 도 같은 방법으로. cache-sg 는 app-sg 허용이 이미 있으니 0.0.0.0/0 만 지우면 돼요.
