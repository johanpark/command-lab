# 설명: www 만 바꾸고 루트 도메인·api 를 빼먹는다
# 실패해야: 기존 서버 IP 를 가리키는 레코드가 남아 있지 않다
Z=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text)
ZN=$(aws route53 list-hosted-zones --query 'HostedZones[0].Name' --output text)
NEW=$(aws ec2 describe-instances --filters Name=tag:Name,Values=web-new Name=instance-state-name,Values=running --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
jq -n --arg n "$NEW" --arg zn "$ZN" '{Changes: [
  {Action: "UPSERT", ResourceRecordSet: {Name: ("www." + $zn), Type: "A", TTL: 300, ResourceRecords: [{Value: $n}]}},
  {Action: "UPSERT", ResourceRecordSet: {Name: ("m." + $zn), Type: "CNAME", TTL: 300, ResourceRecords: [{Value: ("www." + $zn)}]}}]}' > ~/batch.json
aws route53 change-resource-record-sets --hosted-zone-id "$Z" --change-batch file://$HOME/batch.json >/dev/null
