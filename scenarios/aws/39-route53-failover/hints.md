헬스 체크 만들기 (caller-reference 는 아무 고유한 글자):
`aws route53 create-health-check --caller-reference api-$(date +%s) --health-check-config "IPAddress=<운영IP>,Port=443,Type=HTTPS,ResourcePath=/health,RequestInterval=30,FailureThreshold=3" --query HealthCheck.Id --output text`
나온 ID 를 적어 두세요. (`list-health-checks` 에 보이는 HTTP 80 짜리 옛 것은 쓰지 마세요)
---
지금 api 레코드를 그대로 꺼내 두세요. DELETE 할 때는 **지금 값과 정확히 같아야** 해요:
`aws route53 list-resource-record-sets --hosted-zone-id <ID> --query "ResourceRecordSets[?Type=='A' && starts_with(Name,'api.')]"`
---
`batch.json` 에 변경 세 개를 한 번에:
```json
{"Changes": [
  {"Action": "DELETE", "ResourceRecordSet": {"Name": "api.도메인.", "Type": "A", "TTL": 300, "ResourceRecords": [{"Value": "<운영IP>"}]}},
  {"Action": "CREATE", "ResourceRecordSet": {"Name": "api.도메인", "Type": "A", "SetIdentifier": "seoul", "Failover": "PRIMARY", "TTL": 60, "HealthCheckId": "<ID>", "ResourceRecords": [{"Value": "<운영IP>"}]}},
  {"Action": "CREATE", "ResourceRecordSet": {"Name": "api.도메인", "Type": "A", "SetIdentifier": "oregon", "Failover": "SECONDARY", "TTL": 60, "ResourceRecords": [{"Value": "<예비IP>"}]}}
]}
```
