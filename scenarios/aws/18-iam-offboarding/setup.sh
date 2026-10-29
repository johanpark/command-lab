#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
pol() { echo "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"$1\",\"Resource\":\"*\"}]}"; }
for g in developers ops billing-viewers; do aws iam create-group --group-name $g >/dev/null; done
aws iam attach-group-policy --group-name developers --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
aws iam attach-group-policy --group-name ops --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam attach-group-policy --group-name billing-viewers --policy-arn arn:aws:iam::aws:policy/job-function/Billing 2>/dev/null \
  || aws iam attach-group-policy --group-name billing-viewers --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
user() { # 이름 그룹들 [키 개수]
  aws iam create-user --user-name "$1" --tags Key=Team,Value="${4:-dev}" >/dev/null
  aws iam create-login-profile --user-name "$1" --password "Lab-$RANDOM-Pass!2026" >/dev/null
  for g in $2; do aws iam add-user-to-group --user-name "$1" --group-name "$g"; done
  for _ in $(seq "${3:-1}"); do aws iam create-access-key --user-name "$1" >/dev/null; done
}
A=$(rand_pick park-jiwoo park-minsu); B=$(rand_pick lee-seoyeon lee-junho)
user "$A" "developers billing-viewers" 2 dev
aws iam attach-user-policy --user-name "$A" --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam put-user-policy --user-name "$A" --policy-name deploy-lambda --policy-document "$(pol 'lambda:*')"
user "$B" "ops" 1 ops
aws iam put-user-policy --user-name "$B" --policy-name break-glass --policy-document "$(pol 'ec2:*')"
user kim-hana "developers" 1 dev
user choi-dohyun "ops billing-viewers" 2 ops
aws iam attach-user-policy --user-name choi-dohyun --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam create-user --user-name svc-deploy --tags Key=Team,Value=platform >/dev/null
aws iam create-access-key --user-name svc-deploy >/dev/null
aws iam put-user-policy --user-name svc-deploy --policy-name deploy --policy-document "$(pol 's3:PutObject')"
printf '%s\n' "$A" "$B" > $S/gone
# 남는 사람들의 현재 상태 스냅숏
snap() {
  local u=$1
  jq -cn --arg u "$u" \
    --argjson keys "$(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].[AccessKeyId,Status]' --output json)" \
    --argjson groups "$(aws iam list-groups-for-user --user-name "$u" --query 'Groups[].GroupName' --output json)" \
    --argjson att "$(aws iam list-attached-user-policies --user-name "$u" --query 'AttachedPolicies[].PolicyArn' --output json)" \
    --argjson inl "$(aws iam list-user-policies --user-name "$u" --query 'PolicyNames' --output json)" \
    --arg login "$(aws iam get-login-profile --user-name "$u" >/dev/null 2>&1 && echo yes || echo no)" \
    '{u: $u, keys: ($keys | sort), groups: ($groups | sort), att: ($att | sort), inl: ($inl | sort), login: $login}'
}
for u in kim-hana choi-dohyun svc-deploy; do snap "$u"; done > $S/stay
for u in "$A" "$B"; do aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].AccessKeyId' --output text | wc -w > "$S/keys-$u"; done
mkdir -p "$H"
cat > "$H/offboarding.txt" <<TXT
[인사팀] 퇴사자 계정 처리 요청 — 2026-10-29

퇴사자: $A, $B

보안팀 규칙
- 계정과 액세스 키는 감사(로그 추적) 때문에 30일 동안 **삭제 금지**
- 대신 아무것도 못 하게 막을 것:
  · 콘솔 로그인 비밀번호 제거
  · 액세스 키는 모두 **비활성(Inactive)**
  · 모든 그룹에서 빼기
  · 직접 붙은 정책(관리형·인라인) 모두 떼기
- 처리한 계정에는 태그 Status=offboarded 를 달 것 (30일 뒤 일괄 삭제용)
TXT
give "$H/offboarding.txt"
