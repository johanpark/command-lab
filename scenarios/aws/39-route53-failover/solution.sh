P=$(grep -oE '운영 서버 \(서울\): \*\*[0-9.]+' ~/failover-plan.md | grep -oE '[0-9.]+$')
B=$(grep -oE '예비 서버 \(오레곤\): \*\*[0-9.]+' ~/failover-plan.md | grep -oE '[0-9.]+$')
Z=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text)
ZN=$(aws route53 list-hosted-zones --query 'HostedZones[0].Name' --output text)
HC=$(aws route53 create-health-check --caller-reference "api-$(date +%s)" \
  --health-check-config "IPAddress=$P,Port=443,Type=HTTPS,ResourcePath=/health,RequestInterval=30,FailureThreshold=3" \
  --query HealthCheck.Id --output text)
OLD=$(aws route53 list-resource-record-sets --hosted-zone-id "$Z" --query "ResourceRecordSets[?Name=='api.$ZN' && Type=='A'] | [0]" --output json)
jq -n --argjson old "$OLD" --arg n "api.$ZN" --arg p "$P" --arg b "$B" --arg hc "$HC" '{Changes: [
  {Action: "DELETE", ResourceRecordSet: $old},
  {Action: "CREATE", ResourceRecordSet: {Name: $n, Type: "A", SetIdentifier: "seoul", Failover: "PRIMARY", TTL: 60, HealthCheckId: $hc, ResourceRecords: [{Value: $p}]}},
  {Action: "CREATE", ResourceRecordSet: {Name: $n, Type: "A", SetIdentifier: "oregon", Failover: "SECONDARY", TTL: 60, ResourceRecords: [{Value: $b}]}}]}' > ~/batch.json
aws route53 change-resource-record-sets --hosted-zone-id "$Z" --change-batch file://$HOME/batch.json >/dev/null
