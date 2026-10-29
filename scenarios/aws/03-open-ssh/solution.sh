SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=web-sg --query 'SecurityGroups[0].GroupId' --output text)
aws ec2 revoke-security-group-ingress --group-id "$SG" --protocol tcp --port 22 --cidr 0.0.0.0/0 > /dev/null
aws ec2 revoke-security-group-ingress --group-id "$SG" --protocol tcp --port 3306 --cidr 0.0.0.0/0 > /dev/null
aws ec2 revoke-security-group-ingress --group-id "$SG" \
  --ip-permissions '[{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"Ipv6Ranges":[{"CidrIpv6":"::/0"}]}]' > /dev/null
aws ec2 authorize-security-group-ingress --group-id "$SG" --protocol tcp --port 22 --cidr "$(cat ~/office-ip.txt)/32" > /dev/null
aws ec2 describe-security-groups --group-ids "$SG" --query 'SecurityGroups[0].IpPermissions' --output table
