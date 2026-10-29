먼저 그룹 ID 와 규칙을 보세요:
```
aws ec2 describe-security-groups --filters Name=group-name,Values=web-sg --query 'SecurityGroups[0].[GroupId,IpPermissions]' --output json
```
각 규칙의 `IpRanges`(IPv4) 와 `Ipv6Ranges`(IPv6) 를 **둘 다** 보세요.
---
IPv4 규칙 지우기: `aws ec2 revoke-security-group-ingress --group-id sg-... --protocol tcp --port 22 --cidr 0.0.0.0/0` (3306 도 같은 방식). 그런데 22 번은 **IPv6(`::/0`)** 로도 열려 있어요! `--cidr` 는 IPv4 전용이라 다른 방법이 필요해요.
---
IPv6 규칙은 JSON 으로:
```
aws ec2 revoke-security-group-ingress --group-id sg-... \
  --ip-permissions '[{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"Ipv6Ranges":[{"CidrIpv6":"::/0"}]}]'
```
---
사무실만 허용: `aws ec2 authorize-security-group-ingress --group-id sg-... --protocol tcp --port 22 --cidr $(cat ~/office-ip.txt)/32`. 마지막에 규칙 전체를 다시 출력해서 80, 443 은 남아 있는지 확인!
