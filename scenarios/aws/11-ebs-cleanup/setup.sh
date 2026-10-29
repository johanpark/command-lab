#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami); AZ=ap-northeast-2a
vol() { # 크기 이름 [Keep]
  aws ec2 create-volume --size "$1" --availability-zone $AZ \
    --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$2}${3:+,{Key=Keep,Value=$3\}}]" \
    --query VolumeId --output text
}
# 서버 두 대와 거기 붙은 데이터 디스크 (in-use)
: > /opt/cmdlab/secret/inuse
for n in web-1 db-1; do
  i=$(aws ec2 run-instances --image-id "$ami" --instance-type t3.medium --placement AvailabilityZone=$AZ \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$n}]" --query 'Instances[0].InstanceId' --output text)
  v=$(vol "$(rand_pick 50 100 200)" "$n-data")
  aws ec2 attach-volume --volume-id "$v" --instance-id "$i" --device /dev/sdf >/dev/null
  echo "$v" >> /opt/cmdlab/secret/inuse
done
# 지울 대상 (available)
: > /opt/cmdlab/secret/target; total=0
for n in old-web-2-data old-batch-data test-kim-scratch legacy-cms-data $(rand_pick "" "tmp-migration" "perf-test-disk"); do
  s=$(rand_pick 8 20 30 50 100 250); v=$(vol "$s" "$n"); echo "$v" >> /opt/cmdlab/secret/target; total=$((total + s))
done
secret_set freed "$total"
# 보존 (available 이지만 Keep=true), 그리고 Keep=false 는 지울 대상
: > /opt/cmdlab/secret/keep
vol 500 db-restore-2026-10 true >> /opt/cmdlab/secret/keep
s=$(rand_pick 16 32); v=$(vol "$s" old-cache false); echo "$v" >> /opt/cmdlab/secret/target; secret_set freed "$((total + s))"
