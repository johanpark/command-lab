#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
B=config-$(rand_pick shop store mall)-$(rand_int 1000 9999); secret_set bucket "$B"
aws s3 mb "s3://$B" >/dev/null
aws s3api put-bucket-versioning --bucket "$B" --versioning-configuration Status=Enabled
T=$(mktemp -d)
put() { printf '%s\n' "$2" > "$T/f"; aws s3api put-object --bucket "$B" --key "$1" --body "$T/f" --query VersionId --output text; }
mc=$(rand_pick 80 120 150 200); secret_set mc "$mc"
good=$(printf '{"db_host": "db-2.internal", "max_connections": %s, "cache_ttl": 300, "version": "1.4.%s"}' "$mc" "$(rand_int 1 9)")
# staging (시간 순서가 섞이도록 먼저 몇 개)
put staging/app.json '{"db_host": "db-stg.internal", "max_connections": 20, "version": "1.5.0-rc1"}' >/dev/null
put prod/nginx.conf 'server { listen 80; location / { proxy_pass http://127.0.0.1:3000; } }' >/dev/null
put prod/feature-flags.json "{\"new_checkout\": true, \"dark_mode\": false, \"coupon_limit\": $(rand_int 2 5)}" >/dev/null
v1=$(put prod/app.json '{"db_host": "db-1.internal", "max_connections": 50, "cache_ttl": 60, "version": "1.3.2"}'); sleep 1.1
put staging/app.json '{"db_host": "db-stg.internal", "max_connections": 20, "version": "1.5.0-rc2"}' >/dev/null
v2=$(put prod/app.json "$good"); sleep 1.1
# 사고: 배포 스크립트가 덮어쓰고 지움
v3=$(put prod/app.json '{"db_host": "db-2.internal", "max_conn'); sleep 0.2
aws s3 rm "s3://$B/prod/feature-flags.json" >/dev/null
printf '%s\n' "$v1" "$v2" "$v3" > /opt/cmdlab/secret/app-versions
aws s3api list-object-versions --bucket "$B" --prefix prod/feature-flags.json --query 'Versions[0].VersionId' --output text > /opt/cmdlab/secret/ff-version
aws s3api get-object --bucket "$B" --key prod/feature-flags.json --version-id "$(cat /opt/cmdlab/secret/ff-version)" /opt/cmdlab/secret/ff.json >/dev/null
printf '%s\n' "$good" > /opt/cmdlab/secret/good.json
for k in staging/app.json prod/nginx.conf; do
  aws s3api head-object --bucket "$B" --key "$k" --query ETag --output text > "/opt/cmdlab/secret/etag-${k//\//_}"
done
rm -rf "$T"
