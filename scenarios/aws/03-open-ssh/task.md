# 전 세계에 열린 SSH 포트 막기 (보안 그룹)

보안팀 점검 결과가 왔어요.

> **[긴급]** 보안 그룹 `web-sg` 에서 **SSH(22)** 와 **MySQL(3306)** 이 **인터넷 전체**에 열려 있습니다. 무차별 대입 공격 대상이 됩니다.

보안 그룹은 EC2 앞에 있는 **방화벽**이에요. `0.0.0.0/0` 은 "모든 IPv4 주소", `::/0` 은 "모든 IPv6 주소" 라는 뜻이에요.

## 목표 (`web-sg` 의 들어오는(inbound) 규칙)
1. **SSH(22)** 는 사무실 IP 에서만: `~/office-ip.txt` 의 주소 **한 개**만 (`/32`)
2. **MySQL(3306)** 은 인터넷에서 **아예 못 들어오게**
3. **HTTP(80), HTTPS(443)** 는 손님이 들어와야 하니 **그대로 전 세계에 열어 두기**
4. 인터넷 전체(`0.0.0.0/0`, `::/0`)에 열린 22, 3306 규칙이 **하나도 남지 않게**

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-security-groups --filters Name=group-name,Values=web-sg` | 보안 그룹 정보 |
| `... --query 'SecurityGroups[0].IpPermissions'` | 들어오는 규칙만 |
| `aws ec2 revoke-security-group-ingress --group-id sg-... --protocol tcp --port 22 --cidr 0.0.0.0/0` | IPv4 규칙 지우기 |
| `aws ec2 revoke-security-group-ingress --group-id sg-... --ip-permissions '[{...}]'` | 복잡한 규칙(IPv6 등) 지우기 |
| `aws ec2 authorize-security-group-ingress --group-id sg-... --protocol tcp --port 22 --cidr 1.2.3.4/32` | 규칙 추가 |
