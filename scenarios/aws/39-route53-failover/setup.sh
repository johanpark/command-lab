#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ZN=$(rand_pick dalbit haneul bomnal sori)shop.com; secret_set zone "$ZN"
Z=$(aws route53 create-hosted-zone --name "$ZN" --caller-reference "lab-$RANDOM" --query HostedZone.Id --output text); secret_set zid "$Z"
P=13.125.$(rand_int 10 250).$(rand_int 10 250); B=52.12.$(rand_int 10 250).$(rand_int 10 250)
secret_set primary "$P"; secret_set backup "$B"
rr() { printf '{"Action":"CREATE","ResourceRecordSet":{"Name":"%s","Type":"%s","TTL":%s,"ResourceRecords":[{"Value":"%s"}]}}' "$@"; }
aws route53 change-resource-record-sets --hosted-zone-id "$Z" --change-batch "{\"Changes\":[
  $(rr "api.$ZN" A 300 "$P"), $(rr "www.$ZN" A 300 "$P"), $(rr "$ZN" MX 3600 "10 mail.$ZN")]}" >/dev/null
# 예전에 누가 만들다 만 헬스 체크 (HTTP 80, 경로 / → 쓰면 안 됨)
aws route53 create-health-check --caller-reference "old-$RANDOM" \
  --health-check-config "IPAddress=$P,Port=80,Type=HTTP,ResourcePath=/,RequestInterval=30,FailureThreshold=3" >/dev/null
aws route53 list-resource-record-sets --hosted-zone-id "$Z" --output json \
  | jq -c '[.ResourceRecordSets[] | select(.Name | startswith("api.") | not)] | sort_by(.Name, .Type)' > /opt/cmdlab/secret/keep
mkdir -p "$H"
cat > "$H/failover-plan.md" <<MD
# api.$ZN 자동 장애 조치

- 운영 서버 (서울): **$P** — HTTPS 443, 헬스 체크 주소 **/health**
- 예비 서버 (오레곤): **$B** — 평소엔 트래픽 없음

1. 운영 서버용 헬스 체크 만들기
   - HTTPS, 포트 443, 경로 /health, **30초** 간격, **3번** 연속 실패하면 비정상
   - (HTTP 80 / 로 만들다 만 옛 헬스 체크가 있음. 그건 쓰지 말 것)
2. api.$ZN 레코드를 **장애 조치(Failover)** 쌍으로
   - PRIMARY → 운영 서버 IP, 위 헬스 체크 연결
   - SECONDARY → 예비 서버 IP
   - 전환이 빨리 퍼지도록 TTL **60**
3. www 와 MX 는 이번 작업 대상 아님
MD
give "$H/failover-plan.md"
