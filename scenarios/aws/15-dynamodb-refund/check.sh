#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
T=$(secret_get customer); L=$(secret_get last); S=/opt/cmdlab/secret
expect_answer "answer.txt 에 $T 고객의 10월 주문 건수를 적었다" "$(secret_get oct)"
key=$(jq -cn --arg c "$T" --arg o "$L" '{customer_id: {S: $c}, order_id: {S: $o}}')
cur=$(aws dynamodb get-item --table-name orders --key "$key" --output json 2>/dev/null | jq -c '.Item // empty')
orig=$(grep -F "\"$L\"" $S/snapshot)
if [ -z "$cur" ]; then fail "가장 최근 주문($L)을 REFUNDED 로 바꿨다 (주문이 사라졌어요!)"
else
  st=$(jq -r '.status.S // empty' <<< "$cur")
  [ "$st" = REFUNDED ] && pass "가장 최근 주문($L)을 REFUNDED 로 바꿨다" || fail "가장 최근 주문($L)을 REFUNDED 로 바꿨다 (지금: ${st:-없음})"
  [ -n "$(jq -r '.refunded_at | .S // .N // empty' <<< "$cur")" ] && pass "refunded_at 을 기록했다" || fail "refunded_at 을 기록했다"
  [ "$(jq -c '{total, item_count}' <<< "$cur")" = "$(jq -c '{total, item_count}' <<< "$orig")" ] \
    && pass "그 주문의 다른 속성(total, item_count)은 그대로다" || fail "그 주문의 다른 속성(total, item_count)은 그대로다 (put-item 으로 통째로 덮어썼나요?)"
fi
now=$(aws dynamodb scan --table-name orders --output json | jq -c --arg o "$L" '.Items | map(select(.order_id.S != $o)) | sort_by(.customer_id.S, .order_id.S) | .[]')
before=$(grep -vF "\"$L\"" $S/snapshot)
if [ "$now" = "$before" ]; then pass "다른 주문은 하나도 바뀌지 않았다"
else
  n=$(diff <(echo "$before") <(echo "$now") | grep -c '^[<>]')
  fail "다른 주문은 하나도 바뀌지 않았다 (바뀌거나 사라진 줄: ${n}개)"
fi
finish
