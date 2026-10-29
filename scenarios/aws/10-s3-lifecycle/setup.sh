#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
B="shop-logs-$(rand_int 1000 9999)"; secret_set bucket "$B"
aws s3 mb "s3://$B" >/dev/null
echo "$B" > "$H/bucket.txt"; give "$H/bucket.txt"
T=$(mktemp -d); mkdir -p "$T"/{logs/app,logs/nginx,tmp,backups}
for d in 2023-01-01 2024-06-15 2025-10-01 2026-10-28; do echo log > "$T/logs/app/$d.log.gz"; echo log > "$T/logs/nginx/$d.log.gz"; done
for i in 1 2 3; do echo part > "$T/tmp/upload-$RANDOM.part"; done
for d in 2024-12-31 2025-12-31; do echo dump > "$T/backups/db-$d.sql.gz"; done
aws s3 sync "$T/" "s3://$B/" --only-show-errors
