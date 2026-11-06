# 설명: m 을 CNAME 대신 A 레코드로 만들면 IP 가 또 바뀔 때 두 군데를 고쳐야 한다
# 실패해야: A 레코드로 만들었어요
Z=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text)
ZN=$(aws route53 list-hosted-zones --query 'HostedZones[0].Name' --output text)   # 끝에 점(.) 포함
OLD=$(grep -oE '[0-9]+(\.[0-9]+){3}' ~/migration.md | head -1)
NEW=$(aws ec2 describe-instances --filters Name=tag:Name,Values=web-new Name=instance-state-name,Values=running \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
aws route53 list-resource-record-sets --hosted-zone-id "$Z" --output json | jq --arg o "$OLD" --arg n "$NEW" --arg zn "$ZN" '{Changes:
  ([.ResourceRecordSets[] | select(.Type == "A" and any(.ResourceRecords[]; .Value == $o))
    | {Action: "UPSERT", ResourceRecordSet: {Name, Type, TTL, ResourceRecords: [{Value: $n}]}}]
   + [{Action: "UPSERT", ResourceRecordSet: {Name: ("m." + $zn), Type: "A", TTL: 300, ResourceRecords: [{Value: $n}]}}])}' > ~/batch.json
aws route53 change-resource-record-sets --hosted-zone-id "$Z" --change-batch file://$HOME/batch.json >/dev/null
