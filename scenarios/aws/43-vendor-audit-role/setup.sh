#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
VENDOR=$(rand_pick 210987654321 345678901234 456789012345); secret_set vendor "$VENDOR"
XID="sec-audit-$(head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n')"; secret_set xid "$XID"
# 작년에 업체에 준 IAM 사용자 + 액세스 키 (아직 켜져 있다)
aws iam create-user --user-name vendor-audit-2025 --tags Key=Owner,Value=security-team >/dev/null
aws iam attach-user-policy --user-name vendor-audit-2025 --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
aws iam create-access-key --user-name vendor-audit-2025 --query AccessKey.AccessKeyId --output text > /opt/cmdlab/secret/oldkey
# 함정: 비슷한 이름의 다른 팀 키 (건드리면 안 됨)
aws iam create-user --user-name vendor-billing-sync >/dev/null
aws iam create-access-key --user-name vendor-billing-sync --query AccessKey.AccessKeyId --output text > /opt/cmdlab/secret/otherkey
mkdir -p "$H"
cat > "$H/audit-request.md" <<MD
# 보안 감사 업체 접근 요청

올해 외부 보안 감사를 맡은 업체에 우리 AWS 계정 **읽기 전용** 접근을 열어 줘야 합니다.

## 업체 정보
- 업체 AWS 계정 ID: **$VENDOR**
- 업체와 미리 약속한 외부 ID(ExternalId): **$XID**

## 보안팀 요구 사항
1. 작년처럼 IAM 사용자·액세스 키를 주지 말 것 → 업체 계정이 **맡을 수 있는 역할(role)** 로
   - 역할 이름: \`vendor-audit\`
   - **업체 계정만** 맡을 수 있게, 그리고 **외부 ID 가 맞을 때만**
   - 권한: AWS 관리형 정책 **SecurityAudit** 하나만 (보안 설정만 읽을 수 있음, 데이터는 못 봄)
   - 한 번 맡으면 **최대 1시간**
2. 작년에 준 사용자 \`vendor-audit-2025\` 의 액세스 키는 **비활성(Inactive)** 으로. 감사 기록 때문에 **사용자와 키는 지우지 말 것**
MD
give "$H/audit-request.md"
