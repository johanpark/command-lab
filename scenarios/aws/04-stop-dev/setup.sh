#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami)
run() { # 이름 환경 [추가태그]
  aws ec2 run-instances --image-id "$ami" --instance-type t3.medium \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$2}${3:+,$3}]" \
    --query 'Instances[0].InstanceId' --output text
}
for n in web-1 web-2 api-1 api-2 db-primary; do run "$n" prod >/dev/null; done
for n in web api; do run "stg-$n" staging >/dev/null; done
: > /opt/cmdlab/secret/target; : > /opt/cmdlab/secret/keep
for i in $(seq 1 $(rand_int 4 7)); do run "dev-$(rand_pick kim lee park choi)-$i" dev >> /opt/cmdlab/secret/target; done
for i in $(seq 1 $(rand_int 1 2)); do run "dev-ml-train-$i" dev "{Key=KeepRunning,Value=true}" >> /opt/cmdlab/secret/keep; done
# KeepRunning=false 는 끄는 대상 (값까지 봐야 하는 함정)
run "dev-perf-test" dev "{Key=KeepRunning,Value=false}" >> /opt/cmdlab/secret/target
# 이미 꺼진 dev 서버 (세면 안 됨)
old=$(run "dev-old-$(rand_int 1 9)" dev); aws ec2 stop-instances --instance-ids "$old" >/dev/null; echo "$old" > /opt/cmdlab/secret/already
aws ec2 describe-instances --filters Name=tag:Env,Values=prod,staging --query 'Reservations[].Instances[].InstanceId' --output text | tr '\t' '\n' | sort > /opt/cmdlab/secret/prod
