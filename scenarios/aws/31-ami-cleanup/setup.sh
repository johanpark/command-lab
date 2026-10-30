#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
base=$(lab_ami)
I=$(aws ec2 run-instances --image-id "$base" --instance-type t3.small --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=image-builder}]' --query 'Instances[0].InstanceId' --output text)
: > $S/amis   # ami<TAB>snap<TAB>name<TAB>app
mk() { # 이름 앱
  local a s
  a=$(aws ec2 create-image --instance-id "$I" --name "$1" --description "$2 서버 이미지" --query ImageId --output text)
  s=$(aws ec2 describe-images --image-ids "$a" --query 'Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' --output text)
  aws ec2 create-tags --resources "$a" "$s" --tags Key=App,Value="$2" Key=Name,Value="$1"
  printf '%s\t%s\t%s\t%s\n' "$a" "$s" "$1" "$2" >> $S/amis
}
# 만든 순서는 섞임 → 이름의 날짜로 판단해야 함 (가장 최신 이미지를 일부러 맨 먼저 만든다)
mk web-20261020 web
for dt in $(shuf -e 20260714 20260728 20260811 20260825 20260908 20260922 20261006); do mk "web-$dt" web; done
for dt in 20260601 20260901; do mk "batch-$dt" batch; done
# 롤백 때문에 시작 템플릿은 최신이 아닌 이미지를 쓰고 있다
LT_AMI=$(grep -P '\tweb-20260825\t' $S/amis | cut -f1)
aws ec2 create-launch-template --launch-template-name web-lt --launch-template-data "{\"ImageId\":\"$LT_AMI\",\"InstanceType\":\"t3.small\"}" >/dev/null
mkdir -p "$H"
cat > "$H/ami-policy.md" <<'MD'
# web 서버 AMI 보관 규칙

- 이름이 `web-YYYYMMDD` 인 AMI 는 **날짜가 가장 최근인 3개**만 남긴다
- 단, **시작 템플릿(web-lt)이 쓰고 있는 AMI** 는 오래됐어도 남긴다 (지금 롤백 상태)
- 지우는 AMI 는 **등록 해제(deregister)** 하고, 거기에 딸린 **EBS 스냅샷도 지운다**
- batch-* 이미지는 배치팀 담당이라 손대지 않는다
MD
give "$H/ami-policy.md"
