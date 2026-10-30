#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret; ami=$(lab_ami)
B=reports-$(rand_int 1000 9999); secret_set bucket "$B"
aws s3 mb "s3://$B" >/dev/null
aws iam create-user --user-name report-bot >/dev/null
aws iam attach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam put-user-policy --user-name report-bot --policy-name put-reports --policy-document \
  "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"s3:PutObject\",\"Resource\":\"arn:aws:s3:::$B/*\"}]}"
read -r K SK < <(aws iam create-access-key --user-name report-bot --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
secret_set key "$K"
I=$(aws ec2 run-instances --image-id "$ami" --instance-type t3.small \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=report-server}]' --query 'Instances[0].InstanceId' --output text)
secret_set inst "$I"
mkdir -p "$H/report-server"
cat > "$H/report-server/.env" <<ENV
# report-server 설정 (서버의 /srv/report/.env 를 그대로 가져옴)
TZ=Asia/Seoul
REPORT_BUCKET=$B
AWS_ACCESS_KEY_ID=$K
AWS_SECRET_ACCESS_KEY=$SK
AWS_DEFAULT_REGION=ap-northeast-2
SLACK_CHANNEL=#reports
ENV
grep -vE '^AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY)=' "$H/report-server/.env" > $S/env-rest
cat > "$H/report-server/README.md" <<MD
# report-server
매일 아침 매출 보고서를 만들어 S3 버킷 **$B** 에 올리는 서버.
- 읽기: S3 전체 읽기 (AmazonS3ReadOnlyAccess)
- 쓰기: $B 버킷에 보고서 업로드 (s3:PutObject)
- 지금은 IAM 사용자 **report-bot** 의 액세스 키를 .env 에 넣어서 씀 → 보안 점검 지적 사항
MD
give "$H/report-server"
