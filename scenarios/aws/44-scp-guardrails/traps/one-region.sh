# 설명: "us-east-1 이면 거부" 처럼 하나만 막으면 다른 리전은 열려 있다
# 실패해야: 서울 밖 리전
cat > ~/guardrails.json <<'JSON'
{"Version": "2012-10-17",
 "Statement": [
  {"Sid": "DenyOutsideSeoul", "Effect": "Deny",
   "NotAction": ["iam:*", "organizations:*", "sts:*", "route53:*", "cloudfront:*", "support:*", "budgets:*"],
   "Resource": "*",
   "Condition": {"StringEquals": {"aws:RequestedRegion": "us-east-1"}}},
  {"Sid": "DenyGpu", "Effect": "Deny", "Action": "ec2:RunInstances",
   "Resource": "*",
   "Condition": {"StringLike": {"ec2:InstanceType": ["p*", "g*"]}}}]}
JSON
P=$(aws organizations create-policy --name sandbox-guardrails --type SERVICE_CONTROL_POLICY \
  --description "Sandbox: 서울만, GPU 금지" --content file://$HOME/guardrails.json --query Policy.PolicySummary.Id --output text)
SBX=$(aws organizations list-organizational-units-for-parent --parent-id "$(aws organizations list-roots --query 'Roots[0].Id' --output text)" \
  --query "OrganizationalUnits[?Name=='Sandbox'].Id" --output text)
aws organizations attach-policy --policy-id "$P" --target-id "$SBX"
