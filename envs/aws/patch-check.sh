#!/usr/bin/env bash
# patch-moto.py 의 보정이 실제로 동작하는지 이미지 빌드 때 확인한다.
# moto 버전을 올렸을 때 어느 보정이 깨졌는지 바로 알 수 있게, 하나라도 실패하면 빌드를 멈춘다.
set -u
/opt/moto/bin/moto_server -H 127.0.0.1 -p 5000 > /tmp/moto-check.log 2>&1 &
MOTO=$!
. /usr/local/lib/lab-aws.sh
wait_aws || exit 1
bad=0
t() { local msg=$1; shift; if "$@" >/dev/null 2>&1; then echo "✔ $msg"; else echo "✘ $msg"; bad=1; fi; }
eq() { [ "$1" = "$2" ] || { echo "    기대: $2 / 실제: $1" >&2; return 1; }; }

# 1) awscli: sqs 도 AWS_ENDPOINT_URL(가짜 AWS)로 간다 (SSL_COMMON_NAMES 비우기)
t "sqs 가 가짜 AWS 로 간다" aws sqs create-queue --queue-name pc-q

# 2) ECR list-images --filter tagStatus
D=sha256:$(printf '%064d' 1); M='{"schemaVersion":2,"mediaType":"application/vnd.docker.distribution.manifest.v2+json","config":{"digest":"'$D'"},"layers":[]}'
aws ecr create-repository --repository-name pc >/dev/null
aws ecr put-image --repository-name pc --image-tag v1 --image-manifest "$M" --image-manifest-media-type application/vnd.docker.distribution.manifest.v2+json >/dev/null
M2=${M/$D/sha256:$(printf '%064d' 2)}
aws ecr put-image --repository-name pc --image-manifest "$M2" --image-manifest-media-type application/vnd.docker.distribution.manifest.v2+json --image-digest "sha256:$(printf '%s' "$M2" | sha256sum | cut -d' ' -f1)" >/dev/null 2>&1
t "ECR tagStatus=TAGGED 필터" eq "$(aws ecr list-images --repository-name pc --filter tagStatus=TAGGED --query 'length(imageIds)')" 1

# 3) Logs filter-log-events: JSON 패턴, 글자 패턴
aws logs create-log-group --log-group-name /pc; aws logs create-log-stream --log-group-name /pc --log-stream-name s
now=$(($(date +%s) * 1000))
jq -n -c --argjson t "$now" '[{timestamp: $t, message: ({level: "ERROR"} | tojson)},
  {timestamp: $t, message: ({level: "INFO", msg: "ERROR page"} | tojson)}]' > /tmp/pc-events.json
aws logs put-log-events --log-group-name /pc --log-stream-name s --log-events file:///tmp/pc-events.json >/dev/null
t "Logs JSON 패턴 { \$.level = \"ERROR\" }" eq "$(aws logs filter-log-events --log-group-name /pc --filter-pattern '{ $.level = "ERROR" }' --query 'length(events)')" 1
t "Logs 글자 패턴 ERROR -page" eq "$(aws logs filter-log-events --log-group-name /pc --filter-pattern 'ERROR -page' --query 'length(events)')" 1

# 4) Logs put-metric-filter: 같은 이름은 덮어쓰기
for p in ERROR WARN; do aws logs put-metric-filter --log-group-name /pc --filter-name f --filter-pattern $p --metric-transformations metricName=m,metricNamespace=n,metricValue=1; done
t "지표 필터 같은 이름은 덮어쓰기" eq "$(aws logs describe-metric-filters --log-group-name /pc --query 'metricFilters[].filterPattern' --output text)" WARN

# 5) Logs put-retention-policy: 허용 값만
t "보존 기간 35일은 거부" bash -c '! aws logs put-retention-policy --log-group-name /pc --retention-in-days 35'
t "보존 기간 400일은 허용" aws logs put-retention-policy --log-group-name /pc --retention-in-days 400

# 6) S3 get-bucket-replication: 접두사·태그·저장 클래스·삭제 마커
for b in pc-src pc-dst; do aws s3api create-bucket --bucket $b --create-bucket-configuration LocationConstraint=ap-northeast-2 >/dev/null; aws s3api put-bucket-versioning --bucket $b --versioning-configuration Status=Enabled; done
aws s3api put-bucket-replication --bucket pc-src --replication-configuration '{"Role":"arn:aws:iam::123456789012:role/r","Rules":[{"ID":"a","Status":"Enabled","Priority":1,"Filter":{"And":{"Prefix":"orders/","Tags":[{"Key":"k","Value":"v"}]}},"DeleteMarkerReplication":{"Status":"Enabled"},"Destination":{"Bucket":"arn:aws:s3:::pc-dst","StorageClass":"STANDARD_IA"}}]}'
r=$(aws s3api get-bucket-replication --bucket pc-src --output json | jq -c '.ReplicationConfiguration.Rules[0] | [.Filter.And.Prefix, .Filter.And.Tags[0].Key, .Destination.StorageClass, .DeleteMarkerReplication.Status]')
t "S3 복제 규칙 응답(접두사·태그·저장 클래스·삭제 마커)" eq "$r" '["orders/","k","STANDARD_IA","Enabled"]'

# 7) EC2 release-address: 연결된 주소는 InvalidIPAddress.InUse
VPC=$(aws ec2 create-vpc --cidr-block 10.9.0.0/16 --query Vpc.VpcId --output text)
SUB=$(aws ec2 create-subnet --vpc-id "$VPC" --cidr-block 10.9.1.0/24 --query Subnet.SubnetId --output text)
A=$(aws ec2 allocate-address --query AllocationId --output text); aws ec2 create-nat-gateway --subnet-id "$SUB" --allocation-id "$A" >/dev/null
t "연결된 EIP 반납은 InUse 로 거부" bash -c "aws ec2 release-address --allocation-id $A 2>&1 | grep -q InvalidIPAddress.InUse"
F=$(aws ec2 allocate-address --query AllocationId --output text)
t "연결 안 된 EIP 는 반납" aws ec2 release-address --allocation-id "$F"

# 8) Backup: update-backup-plan, 지운 계획 이름 다시 쓰기
aws backup create-backup-vault --backup-vault-name v >/dev/null
P='{"BackupPlanName":"p","Rules":[{"RuleName":"d","TargetBackupVaultName":"v","ScheduleExpression":"cron(0 3 * * ? *)"}]}'
ID=$(aws backup create-backup-plan --backup-plan "$P" --query BackupPlanId --output text)
aws backup update-backup-plan --backup-plan-id "$ID" --backup-plan "${P/0 3/0 18}" >/dev/null
t "update-backup-plan" eq "$(aws backup get-backup-plan --backup-plan-id "$ID" --query 'BackupPlan.Rules[0].ScheduleExpression' --output text)" 'cron(0 18 * * ? *)'
aws backup delete-backup-plan --backup-plan-id "$ID" >/dev/null
t "지운 계획 이름으로 다시 만들기" aws backup create-backup-plan --backup-plan "$P"

kill $MOTO 2>/dev/null
if [ "$bad" != 0 ]; then echo "moto 보정 확인 실패 (moto 로그: /tmp/moto-check.log)"; tail -20 /tmp/moto-check.log; exit 1; fi
rm -f /tmp/moto-check.log /tmp/pc-events.json
