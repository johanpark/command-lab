#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
n=$(rand_int 1000 9999)
SRC=shop-orders-$n; DR=shop-orders-dr-$n
secret_set src "$SRC"; secret_set dr "$DR"
aws s3 mb "s3://$SRC" >/dev/null
aws s3 mb "s3://$DR" --region us-west-2 >/dev/null
trust() { echo "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"$1\"},\"Action\":\"sts:AssumeRole\"}]}"; }
aws iam create-role --role-name s3-replication-role --assume-role-policy-document "$(trust s3.amazonaws.com)" >/dev/null
aws iam put-role-policy --role-name s3-replication-role --policy-name replicate --policy-document \
  "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetReplicationConfiguration\",\"s3:ListBucket\",\"s3:GetObjectVersionForReplication\",\"s3:GetObjectVersionAcl\",\"s3:GetObjectVersionTagging\"],\"Resource\":[\"arn:aws:s3:::$SRC\",\"arn:aws:s3:::$SRC/*\"]},{\"Effect\":\"Allow\",\"Action\":[\"s3:ReplicateObject\",\"s3:ReplicateDelete\",\"s3:ReplicateTags\"],\"Resource\":\"arn:aws:s3:::$DR/*\"}]}"
aws iam create-role --role-name ec2-backup-role --assume-role-policy-document "$(trust ec2.amazonaws.com)" >/dev/null
T=$(mktemp -d)
for k in orders/2026/10/$(rand_int 1000 9999).json orders/2026/10/$(rand_int 1000 9999).json tmp/export-cache.csv tmp/session-dump.bin; do
  echo "{\"k\":\"$k\"}" > "$T/f"; aws s3 cp "$T/f" "s3://$SRC/$k" --quiet
done
rm -rf "$T"
mkdir -p "$H"
cat > "$H/dr-plan.md" <<MD
# 재해 복구(DR) 계획 — 주문 기록

- 원본: **$SRC** (서울, ap-northeast-2)
- 복제본: **$DR** (오레곤, us-west-2) — 이미 만들어 둠
- 복제할 것: **orders/** 아래만 (tmp/ 는 임시 파일이라 제외)
- 복제본은 거의 읽지 않으니 저장 클래스 **STANDARD_IA** 로
- 원본에서 실수로 지운 것이 복제본에서까지 지워지면 안 됨 → **삭제 마커는 복제하지 않음**
- 복제용 IAM 역할은 플랫폼팀이 만들어 둠: **s3-replication-role**
MD
give "$H/dr-plan.md"
