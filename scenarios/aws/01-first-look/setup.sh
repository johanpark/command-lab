#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami)
run() { # 이름 환경 [stopped]
  local id
  id=$(aws ec2 run-instances --image-id "$ami" --instance-type t3.small \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$2}]" \
    --query 'Instances[0].InstanceId' --output text)
  [ "${3:-}" = stopped ] && aws ec2 stop-instances --instance-ids "$id" >/dev/null
  echo "$id"
}
for n in web-1 web-2 shop-api batch-worker; do run "$n" prod >/dev/null; done
pay=$(run payment-api prod)
secret_set pay "$pay"
for n in $(rand_pick "admin legacy-cms" "old-reports legacy-cms" "admin old-reports"); do run "$n" prod stopped >/dev/null; done
for i in $(seq 1 $(rand_int 2 4)); do run "dev-$i" dev >/dev/null; done
for i in $(seq 1 $(rand_int 1 3)); do run "test-$i" dev stopped >/dev/null; done
aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text | wc -w > /opt/cmdlab/secret/running
suffix=$(rand_int 1000 9999)
for b in "shop-assets-$suffix" "shop-backups-$suffix" "shop-logs-$suffix" "terraform-state-$suffix"; do aws s3 mb "s3://$b" >/dev/null; done
aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' | sort > /opt/cmdlab/secret/buckets
