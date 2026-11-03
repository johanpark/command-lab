#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
aws organizations create-organization --feature-set ALL >/dev/null
R=$(aws organizations list-roots --query 'Roots[0].Id' --output text); echo "$R" > $S/root
aws organizations enable-policy-type --root-id "$R" --policy-type SERVICE_CONTROL_POLICY >/dev/null
ou() { aws organizations create-organizational-unit --parent-id "$R" --name "$1" --query OrganizationalUnit.Id --output text; }
PROD=$(ou Production); SBX=$(ou Sandbox); echo "$PROD" > $S/prod; echo "$SBX" > $S/sbx
acct() {
  local id; id=$(aws organizations create-account --account-name "$1" --email "$1@shop.example" --query CreateAccountStatus.AccountId --output text)
  aws organizations move-account --account-id "$id" --source-parent-id "$R" --destination-parent-id "$2"; echo "$id"
}
acct shop-prod "$PROD" > $S/prod-acct
for n in $(rand_pick "dev-minji dev-jun" "dev-seoyeon dev-dohyun dev-haeun" "dev-jiho dev-alex"); do acct "$n" "$SBX"; done > $S/sbx-accts
# 원래 있던 SCP: 조직 탈퇴 금지 (루트에 연결, 그대로 둬야 함)
P=$(aws organizations create-policy --name deny-leave-org --type SERVICE_CONTROL_POLICY --description "계정이 조직을 떠나지 못하게" \
  --content '{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"organizations:LeaveOrganization","Resource":"*"}]}' \
  --query Policy.PolicySummary.Id --output text)
aws organizations attach-policy --policy-id "$P" --target-id "$R"; echo "$P" > $S/leave
mkdir -p "$H"
cat > "$H/scp-request.md" <<'MD'
# 🚧 Sandbox 계정 가드레일 요청

지난달 Sandbox 계정에서 누군가 **버지니아(us-east-1)** 에 **GPU 서버(p3.8xlarge)** 를 켜 두고 퇴근했어요. 2주 뒤에 발견. 💸

Sandbox OU 의 계정들에 아래 제한을 거는 SCP 를 만들어 주세요.

- SCP 이름: `sandbox-guardrails`
1. **서울(ap-northeast-2) 말고 다른 리전**으로 가는 요청은 모두 거부
   - 단, 아래 **전역 서비스**는 리전과 상관없이 허용 (요청이 us-east-1 로 가는 경우가 많아요)
     `iam`, `organizations`, `sts`, `route53`, `cloudfront`, `support`, `budgets`
2. **GPU 인스턴스**(유형이 `p` 나 `g` 로 시작: p3, p4d, g4dn, g5 ...)는 서울에서도 켜지 못하게
   - Graviton(m7g, c6g 처럼 **중간에** g 가 들어간 것)은 막으면 안 돼요
3. **Sandbox OU 에만** 연결. Root 나 Production 에 걸면 운영 서비스가 멈춰요.
4. 기존 SCP(`FullAWSAccess`, `deny-leave-org`)는 건드리지 말 것
MD
give "$H/scp-request.md"
