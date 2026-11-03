#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret; AMI=$(lab_ami)
VPC=$(aws ec2 create-vpc --cidr-block 10.20.0.0/16 --query Vpc.VpcId --output text)
PUB=$(aws ec2 create-subnet --vpc-id "$VPC" --cidr-block 10.20.1.0/24 --query Subnet.SubnetId --output text)
eip() { aws ec2 allocate-address --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=$1}${2:+,$2}]" --query AllocationId --output text; }
run() { aws ec2 run-instances --image-id "$AMI" --instance-type t3.small --subnet-id "$PUB" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" --query 'Instances[0].InstanceId' --output text; }
# NAT 게이트웨이 주소: 연결돼 있지만 InstanceId 는 비어 있다
N=$(eip nat-gw-eip); aws ec2 create-nat-gateway --subnet-id "$PUB" --allocation-id "$N" >/dev/null; echo "$N" > $S/nat
# 운영 서버 2대 (실행 중)
: > $S/web
for w in web-1 web-2; do i=$(run $w); a=$(eip "$w-eip"); aws ec2 associate-address --allocation-id "$a" --instance-id "$i" >/dev/null; echo "$a $i" >> $S/web; done
# 폐기할 서버 (꺼져 있지만 주소는 붙어 있다 → 요금이 나간다)
OB=$(run old-batch); a=$(eip old-batch-eip); aws ec2 associate-address --allocation-id "$a" --instance-id "$OB" >/dev/null
aws ec2 stop-instances --instance-ids "$OB" >/dev/null; echo "$a $OB" > $S/oldbatch
# 파트너 방화벽에 등록된 예약 주소 (지금은 아무 데도 안 붙어 있지만 남겨야 한다)
: > $S/keep
for k in $(seq 1 $(rand_int 1 2)); do eip "partner-reserved-$k" "{Key=Keep,Value=true}" >> $S/keep; done
# 진짜 버려진 주소
: > $S/free
for n in $(rand_pick "test-1 test-2 demo" "poc-a poc-b poc-c lb-old" "temp-1 temp-2 temp-3"); do eip "$n" >> $S/free; done
aws ec2 describe-addresses --query 'Addresses[].AllocationId' --output text | tr '\t' '\n' | sort > $S/all
mkdir -p "$H"
cat > "$H/eip-memo.md" <<'MD'
# Elastic IP 정리 (비용 점검 결과)

퍼블릭 IPv4 주소는 2024년부터 **어디에 붙어 있든 아니든 시간당 요금**이 나가요. (개당 약 $3.6/월)
청구서에 우리가 쓰지도 않는 고정 IP 가 여러 개 보여서 정리합니다.

1. **아무 데도 연결되지 않은** Elastic IP 는 반납(release)
   - 단, `Keep=true` 태그가 붙은 주소는 **파트너사 방화벽에 등록된 예약 주소** → 남겨 두기
2. `old-batch` 서버는 다음 달 폐기 예정 (꺼 둔 상태). **서버는 그대로 두고**, 붙어 있는 주소만 떼서 반납
3. 운영 서버(web-1, web-2)와 **NAT 게이트웨이**의 주소는 절대 건드리지 말 것
MD
give "$H/eip-memo.md"
