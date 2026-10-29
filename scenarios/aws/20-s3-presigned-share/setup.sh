#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
B=finance-docs-$(rand_int 1000 9999); secret_set bucket "$B"
aws s3 mb "s3://$B" >/dev/null
aws s3api put-public-access-block --bucket "$B" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
T=$(mktemp -d)
for k in reports/2026-08-settlement.xlsx reports/2026-09-settlement.xlsx reports/2026-10-settlement.xlsx reports/2026-10-settlement-draft.xlsx \
         payroll/2026-10-salary.xlsx contracts/vendor-a.pdf; do
  head -c "$(rand_int 2000 9000)" /dev/urandom > "$T/f"
  aws s3 cp "$T/f" "s3://$B/$k" --quiet
  [ "$k" = reports/2026-10-settlement.xlsx ] && sha256sum < "$T/f" | cut -d' ' -f1 > $S/sha
done
rm -rf "$T"
mkdir -p "$H"
cat > "$H/request.txt" <<TXT
From: 한결회계법인 김회계사
안녕하세요. 10월 결산 검토를 위해 **10월 정산 확정본** 파일을 받을 수 있을까요?
(파일 보관 버킷: $B)

[내부 메모 - 보안팀]
- 버킷 공개, 외부인 IAM 계정 발급 금지
- 미리 서명된 URL 로, 유효기간은 딱 **24시간**
- 만든 링크는 ~/share-url.txt 에 한 줄로 저장 → 메일로 보낼 예정
TXT
give "$H/request.txt"
