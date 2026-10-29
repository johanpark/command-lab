# 해설

```bash
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=web-sg --query 'SecurityGroups[0].GroupId' --output text)
aws ec2 revoke-security-group-ingress --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 revoke-security-group-ingress --group-id $SG --protocol tcp --port 3306 --cidr 0.0.0.0/0
aws ec2 revoke-security-group-ingress --group-id $SG \
  --ip-permissions '[{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"Ipv6Ranges":[{"CidrIpv6":"::/0"}]}]'
aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 22 --cidr "$(cat ~/office-ip.txt)/32"
```

## IPv6 를 잊지 마세요
`0.0.0.0/0` 만 지우고 안심하면, `::/0` 규칙으로 **IPv6 주소를 가진 누구나** 여전히 들어올 수 있어요. 인터넷의 상당 부분이 이미 IPv6 를 써요. 점검할 때는 `IpRanges` 와 `Ipv6Ranges` 를 함께 보세요.

## 보안 그룹 규칙의 원칙
| 포트 | 권장 |
|---|---|
| 80, 443 (웹) | 전 세계 OK (그래야 손님이 와요) |
| 22 (SSH) | 사무실·VPN IP 만. 더 좋은 건 **SSM Session Manager** 로 22번을 아예 닫기 |
| 3306, 5432 (DB) | 인터넷 X. **앱 서버의 보안 그룹**에서만 (`--source-group sg-앱서버`) |

보안 그룹은 **허용 목록**만 있어요. 막는 규칙이 따로 없고, 허용하지 않은 건 다 막혀요. 그래서 "허용 규칙을 지우는 것" 이 곧 막는 방법이에요.

## 다시 생기지 않게
- AWS Config 규칙 `restricted-ssh`, Security Hub 로 열린 22 번을 자동 감지
- Terraform 같은 코드로 보안 그룹을 관리하면 누가 언제 열었는지 기록이 남아요
