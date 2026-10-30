#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret; ami=$(lab_ami); AZ=ap-northeast-2a
vol() { # 크기 타입 이름 [보류]
  local t="{Key=Name,Value=$3}"; [ -n "$4" ] && t+=",{Key=Migration,Value=hold}"
  local extra=""; [ "$2" = io1 ] && extra="--iops 5000"
  aws ec2 create-volume --size "$1" --volume-type "$2" $extra --availability-zone $AZ \
    --tag-specifications "ResourceType=volume,Tags=[$t]" --query VolumeId --output text
}
: > $S/plan   # id<TAB>이름<TAB>원래타입<TAB>기대타입<TAB>크기
add() { printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" >> $S/plan; }
total=0
for n in web-1 web-2 api-1; do
  i=$(aws ec2 run-instances --image-id "$ami" --instance-type t3.medium --placement AvailabilityZone=$AZ \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$n}]" --query 'Instances[0].InstanceId' --output text)
  s=$(rand_pick 50 100 200); v=$(vol "$s" gp2 "$n-data")
  aws ec2 attach-volume --volume-id "$v" --instance-id "$i" --device /dev/sdf >/dev/null
  add "$v" "$n-data" gp2 gp3 "$s"; total=$((total + s))
done
s=$(rand_pick 500 1000); v=$(vol "$s" gp2 log-archive); add "$v" log-archive gp2 gp3 "$s"; total=$((total + s))
v=$(vol 300 gp2 legacy-oracle hold); add "$v" legacy-oracle gp2 gp2 300
v=$(vol 1000 io1 db-primary); add "$v" db-primary io1 io1 1000
v=$(vol 100 gp3 new-service); add "$v" new-service gp3 gp3 100
# 서버의 루트 디스크(gp2)도 대상이다 → 실제 gp2 볼륨 전체에서 다시 계산
while read -r v sz i; do
  grep -q "^$v" $S/plan && continue
  add "$v" "$(aws ec2 describe-instances --instance-ids "$i" --query "Reservations[0].Instances[0].Tags[?Key=='Name']|[0].Value" --output text)-root" gp2 gp3 "$sz"
done < <(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query 'Volumes[].[VolumeId,Size,Attachments[0].InstanceId]' --output text)
total=$(awk -F'\t' '$3 == "gp2" && $4 == "gp3" { s += $5 } END { print s }' $S/plan)
secret_set total "$total"
secret_set saving "$(python3 -c "print(f'{$total * (0.114 - 0.0912):.2f}')")"
mkdir -p "$H"
cat > "$H/ebs-memo.md" <<'MD'
# EBS gp2 → gp3 전환 (비용 절감 TF)

- 서울 리전 요금: gp2 **$0.114** / GB·월, gp3 **$0.0912** / GB·월 (기본 3000 IOPS·125MB/s 포함)
- 전환은 **서버를 멈추지 않고** 온라인으로 가능 (modify-volume)
- 대상: **gp2 볼륨 전부**. 단,
  - `Migration=hold` 태그가 있는 것은 제외 (벤더 인증 문제로 보류)
  - io1/io2 (DB 전용 고성능 디스크) 는 이번 대상 아님
- 끝나면 **이번에 바꾼 볼륨들로 한 달에 아끼는 금액(달러, 소수점 둘째 자리)** 을 ~/saving.txt 에 숫자만
MD
give "$H/ebs-memo.md"
