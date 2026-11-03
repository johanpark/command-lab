#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
SRC=$(secret_get src); DR=$(secret_get dr)
for b in "$SRC" "$DR"; do
  v=$(aws s3api get-bucket-versioning --bucket "$b" --query Status --output text 2>/dev/null); [ "$v" = None ] && v=""
  [ "$v" = Enabled ] && pass "$b 의 버전 관리가 켜져 있다" || fail "$b 의 버전 관리가 켜져 있다 (지금: ${v:-꺼짐})"
done
C=$(aws s3api get-bucket-replication --bucket "$SRC" --output json 2>/dev/null | jq -c .ReplicationConfiguration)
if [ -z "$C" ]; then fail "$SRC 에 복제 규칙이 있다"; finish; fi
role=$(jq -r .Role <<< "$C")
[ "$role" = arn:aws:iam::123456789012:role/s3-replication-role ] && pass "복제용 역할 s3-replication-role 을 쓴다" \
  || fail "복제용 역할 s3-replication-role 을 쓴다 (지금: $role — S3 가 맡을 수 있는 역할이어야 해요)"
# 켜진 규칙들을 (접두사, 태그 필터 수, 대상, 저장 클래스, 삭제 마커) 로 정리
rules=$(jq -c '.Rules[] | select(.Status == "Enabled") | {p: (.Filter.Prefix // .Filter.And.Prefix // .Prefix // ""),
  t: ([.Filter.Tag // empty] + (.Filter.And.Tags // []) | length),
  b: .Destination.Bucket, sc: (.Destination.StorageClass // "STANDARD"), dm: (.DeleteMarkerReplication.Status // "Disabled")}' <<< "$C")
if [ -z "$rules" ]; then fail "orders/ 만 복제본 버킷으로 복제한다 (켜진 규칙이 없어요)"; finish; fi
show() { jq -r '(if .p == "" then "(전부)" else .p end) + (if .t > 0 then "+태그" else "" end)' <<< "$rules" | paste -sd' '; }
# 1) 켜진 규칙은 전부 orders/ 안쪽만 2) 그중 하나는 orders/ 전체를 (태그 조건 없이)
if [ -n "$(jq -c 'select(.p | startswith("orders/") | not)' <<< "$rules")" ]; then
  fail "orders/ 만 복제본 버킷으로 복제한다 (orders/ 밖까지 복제해요 — 지금 규칙: $(show))"
elif ! jq -e 'select(.p == "orders/" and .t == 0)' <<< "$rules" >/dev/null; then
  fail "orders/ 만 복제본 버킷으로 복제한다 (주문 기록 일부만 복제돼요 — 지금 규칙: $(show). 접두사는 orders/ 그대로, 태그 조건 없이)"
elif grep -v "\"b\":\"arn:aws:s3:::$DR\"" <<< "$rules" | grep -q .; then
  fail "orders/ 만 복제본 버킷으로 복제한다 (대상 버킷이 달라요: $(jq -r .b <<< "$rules" | paste -sd' '))"
else pass "orders/ 만 복제본 버킷으로 복제한다"; fi
sc=$(jq -r .sc <<< "$rules" | sort -u | paste -sd' ')
[ "$sc" = STANDARD_IA ] && pass "복제본은 STANDARD_IA 로 저장한다" || fail "복제본은 STANDARD_IA 로 저장한다 (지금: $sc)"
dm=$(jq -r .dm <<< "$rules" | sort -u | paste -sd' ')
[ "$dm" = Disabled ] && pass "삭제 마커는 복제하지 않는다" || fail "삭제 마커는 복제하지 않는다 (지금: $dm — 원본에서 실수로 지우면 복제본에서도 사라져요)"
finish
