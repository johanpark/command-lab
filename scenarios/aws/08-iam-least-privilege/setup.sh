#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
sfx=$(rand_int 1000 9999); B="reports-$sfx"
secret_set bucket "$B"; secret_set other "finance-$sfx"
aws s3 mb "s3://$B" >/dev/null; aws s3 mb "s3://finance-$sfx" >/dev/null
echo "$B" > "$H/bucket.txt"; give "$H/bucket.txt"
aws iam create-user --user-name report-bot >/dev/null
aws iam attach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name report-bot >/dev/null
# 다른 사용자 (건드리면 안 됨)
aws iam create-user --user-name deploy-bot >/dev/null
aws iam attach-user-policy --user-name deploy-bot --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
