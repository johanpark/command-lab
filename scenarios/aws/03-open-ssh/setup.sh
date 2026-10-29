#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
office="203.0.113.$(rand_int 10 250)"
echo "$office" > "$H/office-ip.txt"; give "$H/office-ip.txt"
secret_set office "$office"
SG=$(aws ec2 create-security-group --group-name web-sg --description "web servers" --query GroupId --output text)
OTHER=$(aws ec2 create-security-group --group-name batch-sg --description "batch" --query GroupId --output text)
secret_set sg "$SG"; secret_set other "$OTHER"
aws ec2 authorize-security-group-ingress --group-id "$SG" --ip-permissions '[
  {"IpProtocol":"tcp","FromPort":80,"ToPort":80,"IpRanges":[{"CidrIp":"0.0.0.0/0"}],"Ipv6Ranges":[{"CidrIpv6":"::/0"}]},
  {"IpProtocol":"tcp","FromPort":443,"ToPort":443,"IpRanges":[{"CidrIp":"0.0.0.0/0"}],"Ipv6Ranges":[{"CidrIpv6":"::/0"}]},
  {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}],"Ipv6Ranges":[{"CidrIpv6":"::/0"}]},
  {"IpProtocol":"tcp","FromPort":3306,"ToPort":3306,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}
]' >/dev/null
aws ec2 authorize-security-group-ingress --group-id "$OTHER" --protocol tcp --port 22 --cidr 10.0.0.0/16 >/dev/null
aws ec2 describe-security-groups --group-ids "$OTHER" --query 'SecurityGroups[0].IpPermissions' --output json > /opt/cmdlab/secret/other.json
