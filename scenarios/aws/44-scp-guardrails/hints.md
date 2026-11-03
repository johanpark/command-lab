SCP 는 문장 두 개면 돼요. 둘 다 `"Effect": "Deny"`, `"Resource": "*"`.
① 리전 막기 ② GPU 막기. 먼저 `aws organizations list-policies-for-target --target-id $(aws organizations list-roots --query 'Roots[0].Id' --output text) --filter SERVICE_CONTROL_POLICY` 로 지금 루트에 뭐가 붙어 있는지 보세요.
---
① 리전: "전역 서비스를 **빼고**(NotAction) 모든 요청을, 리전이 서울이 **아니면**(StringNotEquals) 거부"
```json
{"Effect": "Deny", "NotAction": ["iam:*", "organizations:*", "sts:*", "route53:*", "cloudfront:*", "support:*", "budgets:*"],
 "Resource": "*", "Condition": {"StringNotEquals": {"aws:RequestedRegion": "ap-northeast-2"}}}
```
`"Action": "*"` 로 쓰면 IAM 같은 전역 서비스까지 막혀요 (IAM 요청은 us-east-1 로 가요).
---
② GPU: `{"Effect": "Deny", "Action": "ec2:RunInstances", "Resource": "*", "Condition": {"StringLike": {"ec2:InstanceType": ["p*", "g*"]}}}`
⚠️ `"*g*"` 처럼 쓰면 `m7g`, `c6g` 같은 Graviton 도 걸려요. **맨 앞 글자**만 보도록 `g*`.
---
두 문장을 `{"Version": "2012-10-17", "Statement": [①, ②]}` 로 묶어 `scp.json` 에 저장 → `create-policy --content file://scp.json` → Sandbox OU ID(`list-organizational-units-for-parent`) 로 `attach-policy`. 루트에 붙이면 운영 계정까지 막혀요. 내용을 고칠 땐 `update-policy`.
