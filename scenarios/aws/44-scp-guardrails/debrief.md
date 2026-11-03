# 해설

```json
{"Version": "2012-10-17",
 "Statement": [
  {"Sid": "DenyOutsideSeoul", "Effect": "Deny",
   "NotAction": ["iam:*", "organizations:*", "sts:*", "route53:*", "cloudfront:*", "support:*", "budgets:*"],
   "Resource": "*",
   "Condition": {"StringNotEquals": {"aws:RequestedRegion": "ap-northeast-2"}}},
  {"Sid": "DenyGpu", "Effect": "Deny", "Action": "ec2:RunInstances", "Resource": "*",
   "Condition": {"StringLike": {"ec2:InstanceType": ["p*", "g*"]}}}]}
```
```bash
P=$(aws organizations create-policy --name sandbox-guardrails --type SERVICE_CONTROL_POLICY \
  --description "Sandbox: 서울만, GPU 금지" --content file://scp.json --query Policy.PolicySummary.Id --output text)
aws organizations attach-policy --policy-id $P --target-id ou-xxxx-sandbox
```

## SCP 는 "울타리", IAM 은 "열쇠"
```
실제로 할 수 있는 것 = (IAM 이 허용한 것) ∩ (SCP 가 막지 않은 것)
```
- SCP 는 권한을 **주지 않아요.** Sandbox 계정 관리자가 `AdministratorAccess` 를 갖고 있어도 SCP 가 막으면 못 해요. 루트 사용자도 마찬가지.
- 루트 → OU → 계정 **단계마다 Allow 가 하나는 있어야** 통과해요. 그 Allow 가 기본으로 붙어 있는 `FullAWSAccess` 예요. 이걸 떼면 그 아래 계정은 **아무것도 못 해요.**
- 그래서 보통은 `FullAWSAccess` 는 두고, **Deny 문장을 더하는** 방식(거부 목록)으로 써요.

## 왜 NotAction 인가
IAM, Organizations, STS, Route 53, CloudFront 같은 **전역 서비스**는 요청이 `us-east-1` 로 가요. `"Action": "*"` + "서울이 아니면 거부" 로 쓰면 이것들까지 막혀서, Sandbox 계정에서 IAM 역할 하나 못 만들어요. "이것들 **빼고** 전부(NotAction)" 를 쓰는 이유예요.

## g* 와 *g*
| 패턴 | p3.8xlarge | g5.xlarge | m7g.large (Graviton) |
|---|---|---|---|
| `g*`, `p*` | 막음 | 막음 | 통과 ✅ |
| `*g*` | 통과 | 막음 | **막음** ❌ |

## 실무 팁
- SCP 는 **관리 계정**에는 적용되지 않아요. 관리 계정에선 리소스를 아예 만들지 않는 게 원칙.
- 새 SCP 는 먼저 테스트 OU 에 걸어 보고 넓혀요. 잘못 걸면 그 아래 모든 계정이 한 번에 멈춰요.
- 리전 제한은 Control Tower 의 "Region deny" 컨트롤로도 걸 수 있어요 (내부적으로 같은 SCP).
