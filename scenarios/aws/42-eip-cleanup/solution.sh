# 1) 아무 데도 연결 안 됐고(AssociationId 없음) Keep=true 가 아닌 주소
aws ec2 describe-addresses --output json \
  | jq -r '.Addresses[] | select(.AssociationId == null) | select(any(.Tags[]?; .Key == "Keep" and .Value == "true") | not) | .AllocationId' \
  | while read -r a; do aws ec2 release-address --allocation-id "$a"; done
# 2) old-batch: 연결을 끊고 반납
OB=$(aws ec2 describe-instances --filters Name=tag:Name,Values=old-batch --query 'Reservations[0].Instances[0].InstanceId' --output text)
read -r AS AL < <(aws ec2 describe-addresses --filters Name=instance-id,Values="$OB" --query 'Addresses[0].[AssociationId,AllocationId]' --output text)
aws ec2 disassociate-address --association-id "$AS"
aws ec2 release-address --allocation-id "$AL"
