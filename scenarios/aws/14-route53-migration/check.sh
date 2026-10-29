#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
Z=$(secret_get zid); ZN=$(secret_get zone); OLD=$(secret_get old); NEW=$(secret_get new); S=/opt/cmdlab/secret
RS=$(aws route53 list-resource-record-sets --hosted-zone-id "$Z" --output json 2>/dev/null)
vals() { jq -r --arg n "$1" --arg t "$2" '.ResourceRecordSets[] | select(.Name == $n and .Type == $t) | .ResourceRecords[].Value' <<< "$RS" | sort | tr '\n' ' ' | sed 's/ $//'; }
for n in "$ZN." "www.$ZN." "api.$ZN."; do
  got=$(vals "$n" A)
  if [ "$got" = "$NEW" ]; then pass "${n%.} → 새 서버($NEW)"
  elif [ "$got" = "$OLD" ]; then fail "${n%.} → 새 서버 (아직 기존 서버 IP 예요)"
  elif [ "$got" = "$(secret_get test)" ]; then fail "${n%.} → 새 서버 (그건 web-new-test 의 IP 예요)"
  else fail "${n%.} → 새 서버 (지금: ${got:-레코드 없음})"; fi
done
left=$(jq -r --arg o "$OLD" '[.ResourceRecordSets[] | select(any(.ResourceRecords[]?; .Value == $o)) | .Name] | join(", ")' <<< "$RS")
[ -z "$left" ] && pass "기존 서버 IP 를 가리키는 레코드가 남아 있지 않다" || fail "기존 서버 IP 를 가리키는 레코드가 남아 있지 않다 (남음: $left)"
m=$(vals "m.$ZN." CNAME)
if [ "${m%.}" = "www.$ZN" ]; then pass "m.$ZN 이 www 의 CNAME 이다"
elif [ -n "$(vals "m.$ZN." A)" ]; then fail "m.$ZN 이 www 의 CNAME 이다 (A 레코드로 만들었어요. IP 가 또 바뀌면 두 군데를 고쳐야 해요)"
else fail "m.$ZN 이 www 의 CNAME 이다 (지금: ${m:-레코드 없음})"; fi
keep=$(jq -c '[.ResourceRecordSets[] | select(.Type == "MX" or .Type == "TXT" or .Type == "NS" or (.Name | startswith("admin.") or startswith("status.")))] | sort_by(.Name, .Type)' <<< "$RS")
[ "$keep" = "$(cat $S/keep.json)" ] && pass "메일·인증·admin·status 레코드는 그대로다" || fail "메일·인증·admin·status 레코드는 그대로다 (바뀌었거나 지워졌어요)"
finish
