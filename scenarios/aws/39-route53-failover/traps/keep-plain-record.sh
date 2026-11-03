# 설명: 기존 일반 A 레코드를 두고, 계획과 다른 헬스 체크를 쓰고, TTL 을 다르게 둔다
# 실패해야: 일반 A 레코드를 없앴다
# 실패해야: 헬스 체크가 계획과 달라요
# 실패해야: TTL 이 60
P=$(grep -oE '운영 서버 \(서울\): \*\*[0-9.]+' ~/failover-plan.md | grep -oE '[0-9.]+$'); B=$(grep -oE '예비 서버 \(오레곤\): \*\*[0-9.]+' ~/failover-plan.md | grep -oE '[0-9.]+$')
Z=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text); ZN=$(aws route53 list-hosted-zones --query 'HostedZones[0].Name' --output text)
HC=$(aws route53 list-health-checks --query 'HealthChecks[0].Id' --output text)
jq -n --arg n "api.$ZN" --arg p "$P" --arg b "$B" --arg hc "$HC" '{Changes: [
 {Action: "CREATE", ResourceRecordSet: {Name: $n, Type: "A", SetIdentifier: "a", Failover: "PRIMARY", TTL: 60, HealthCheckId: $hc, ResourceRecords: [{Value: $p}]}},
 {Action: "CREATE", ResourceRecordSet: {Name: $n, Type: "A", SetIdentifier: "b", Failover: "SECONDARY", TTL: 300, ResourceRecords: [{Value: $b}]}}]}' > b.json
aws route53 change-resource-record-sets --hosted-zone-id $Z --change-batch file://b.json
