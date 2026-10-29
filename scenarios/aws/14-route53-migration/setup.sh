#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami); S=/opt/cmdlab/secret
ZN=$(rand_pick dalbit haneul bomnal sori)shop.com; secret_set zone "$ZN"
Z=$(aws route53 create-hosted-zone --name "$ZN" --caller-reference "lab-$RANDOM" --query HostedZone.Id --output text)
secret_set zid "$Z"
OLD=13.125.$(rand_int 10 250).$(rand_int 10 250); ADMIN=3.35.$(rand_int 10 250).$(rand_int 10 250)
secret_set old "$OLD"; secret_set admin "$ADMIN"
inst() { aws ec2 run-instances --image-id "$ami" --instance-type t3.small \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" --query 'Instances[0].InstanceId' --output text; }
TI=$(inst web-new-test)
secret_set test "$(aws ec2 describe-instances --instance-ids "$TI" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"
NEWI=$(inst web-new)
secret_set new "$(aws ec2 describe-instances --instance-ids "$NEWI" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"
rr() { printf '{"Action":"CREATE","ResourceRecordSet":{"Name":"%s","Type":"%s","TTL":%s,"ResourceRecords":[%s]}}' "$1" "$2" "$3" "$4"; }
v() { local o="" x; for x in "$@"; do o+="${o:+,}{\"Value\":$(jq -Rn --arg s "$x" '$s')}"; done; echo "$o"; }
changes=$(printf '%s,' \
  "$(rr "$ZN" A 300 "$(v "$OLD")")" \
  "$(rr "www.$ZN" A 300 "$(v "$OLD")")" \
  "$(rr "api.$ZN" A 60 "$(v "$OLD")")" \
  "$(rr "admin.$ZN" A 300 "$(v "$ADMIN")")" \
  "$(rr "$ZN" MX 3600 "$(v "10 aspmx.mailhost.example." "20 alt.mailhost.example.")")" \
  "$(rr "$ZN" TXT 3600 "$(v '"v=spf1 include:_spf.mailhost.example ~all"')")" \
  "$(rr "status.$ZN" CNAME 300 "$(v "statuspage.example.net")")")
aws route53 change-resource-record-sets --hosted-zone-id "$Z" --change-batch "{\"Changes\":[${changes%,}]}" >/dev/null
aws route53 list-resource-record-sets --hosted-zone-id "$Z" --output json \
  | jq -c '[.ResourceRecordSets[] | select(.Type == "MX" or .Type == "TXT" or .Type == "NS" or (.Name | startswith("admin.") or startswith("status.")))] | sort_by(.Name, .Type)' > $S/keep.json
mkdir -p "$H"
cat > "$H/migration.md" <<MD
# 서버 이사 작업 메모

- 기존 웹 서버 IP: **$OLD** (오늘 밤 종료 예정)
- 새 웹 서버: EC2 \`web-new\` (공인 IP 는 EC2 에서 확인. \`web-new-test\` 는 테스트용이라 아님!)
- 할 일
  1. 기존 서버 IP 를 가리키는 **A 레코드 전부** → 새 서버 IP 로
  2. 모바일 주소 \`m.$ZN\` 추가 → \`www.$ZN\` 의 별칭(CNAME)
- 주의: 메일(MX), 인증(TXT), 관리자 서버(admin), 상태 페이지(status) 는 그대로!
MD
give "$H/migration.md"
