#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
sfx=$(rand_int 1000 9999)
W="shop-website-$sfx"; bad="$(rand_pick customer-exports order-reports crm-dumps)-$sfx"
secret_set bad "$bad"; secret_set web "$W"
for b in "$W" "$bad" "shop-backups-$sfx" "shop-logs-$sfx"; do aws s3 mb "s3://$b" >/dev/null; done
pub() { echo '{"Version":"2012-10-17","Statement":[{"Sid":"PublicRead","Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::'"$1"'/*"}]}'; }
aws s3api put-bucket-policy --bucket "$W" --policy "$(pub "$W")"
aws s3api put-bucket-policy --bucket "$bad" --policy "$(pub "$bad")"
# 비공개 정책이 있는 버킷 (내부 역할만 허용)
aws s3api put-bucket-policy --bucket "shop-backups-$sfx" --policy '{"Version":"2012-10-17","Statement":[{"Sid":"BackupRole","Effect":"Allow","Principal":{"AWS":"arn:aws:iam::123456789012:role/backup"},"Action":"s3:PutObject","Resource":"arn:aws:s3:::shop-backups-'"$sfx"'/*"}]}'
T=$(mktemp -d); echo "<h1>shop</h1>" > "$T/index.html"; aws s3 cp "$T/index.html" "s3://$W/index.html" >/dev/null
printf 'order_id,name,phone,address\n1001,김민수,010-1234-5678,서울시 ...\n' > "$T/orders.csv"
aws s3 cp "$T/orders.csv" "s3://$bad/2026-10/orders.csv" >/dev/null
for b in "$W" "shop-backups-$sfx"; do aws s3api get-bucket-policy --bucket "$b" --query Policy --output text > "/opt/cmdlab/secret/policy-$b"; done
echo "shop-backups-$sfx" > /opt/cmdlab/secret/backups
