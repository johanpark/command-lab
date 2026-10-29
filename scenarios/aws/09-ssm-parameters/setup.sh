#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
mkdir -p "$H/app"; rm -f "$H/app/.env"; give "$H/app"
put() { aws ssm put-parameter --name "$1" --value "$2" --type "$3" >/dev/null; }
: > /opt/cmdlab/secret/expected
p() { put "/prod/shop/$1" "$2" "$3"; echo "$(echo "$1" | tr a-z A-Z)=$2" >> /opt/cmdlab/secret/expected; }
p db_host "prod-db-$(rand_int 1 9).cluster-$(rand_int 100000 999999).ap-northeast-2.rds.amazonaws.com" String
p db_port 5432 String
p db_user shop_app String
p db_password "Pg$(rand_int 1000 9999)!$(rand_pick xq vz mk)" SecureString
p payment_api_key "pk_live_$(rand_int 100000 999999)" SecureString
p log_level warn String
for k in db_host db_password log_level; do put "/staging/shop/$k" "staging-$k-$(rand_int 1 99)" "$( [ $k = db_password ] && echo SecureString || echo String)"; done
put /prod/batch/db_host "batch-db.internal" String
sort -o /opt/cmdlab/secret/expected /opt/cmdlab/secret/expected
