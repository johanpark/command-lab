영역 ID 와 레코드를 표로: `aws route53 list-hosted-zones --query "HostedZones[].[Id,Name]" --output table`
`aws route53 list-resource-record-sets --hosted-zone-id ID --query "ResourceRecordSets[].[Name,Type,TTL,ResourceRecords[0].Value]" --output table`
기존 IP 를 가리키는 A 레코드는 **세 개**예요 (도메인 자체 포함).
---
새 서버 IP: `aws ec2 describe-instances --filters Name=tag:Name,Values=web-new --query 'Reservations[].Instances[].PublicIpAddress' --output text`
(`web-new-test` 와 헷갈리지 않게 이름을 정확히!)
---
`vim ~/batch.json` 으로 Changes 에 4개(A 3개 UPSERT + m CNAME 1개)를 넣어요. 이름은 `www.도메인.` 처럼 끝에 점이 있어도 없어도 돼요.
CNAME 은 `{"Name": "m.도메인", "Type": "CNAME", "TTL": 300, "ResourceRecords": [{"Value": "www.도메인"}]}`
---
적용: `aws route53 change-resource-record-sets --hosted-zone-id ID --change-batch file://batch.json`
JSON 문법이 틀리면 에러가 나니 먼저 `jq . batch.json` 으로 확인하세요.
