id() { aws ec2 describe-security-groups --filters Name=group-name,Values="$1" --query 'SecurityGroups[0].GroupId' --output text; }
DB=$(id db-sg); CACHE=$(id cache-sg); APP=$(id app-sg); BAS=$(id bastion-sg)
for g in "$DB" "$CACHE"; do
  r=$(aws ec2 describe-security-group-rules --filters Name=group-id,Values="$g" \
    --query 'SecurityGroupRules[?!IsEgress && (CidrIpv4 || CidrIpv6)].SecurityGroupRuleId' --output text)
  [ -n "$r" ] && aws ec2 revoke-security-group-ingress --group-id "$g" --security-group-rule-ids $r >/dev/null
done
aws ec2 authorize-security-group-ingress --group-id "$DB" --protocol tcp --port 5432 --source-group "$APP" >/dev/null
aws ec2 authorize-security-group-ingress --group-id "$DB" --protocol tcp --port 5432 --source-group "$BAS" >/dev/null
