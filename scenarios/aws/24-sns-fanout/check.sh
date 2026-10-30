#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
T=$(secret_get topic)
qarn() { echo "arn:aws:sqs:ap-northeast-2:123456789012:$1"; }
url() { aws sqs get-queue-url --queue-name "$1" --query QueueUrl --output text 2>/dev/null; }
SUBS=$(aws sns list-subscriptions-by-topic --topic-arn "$T" --output json 2>/dev/null)
sub_of() { jq -r --arg e "$(qarn "$1")" '[.Subscriptions[] | select(.Protocol == "sqs" and .Endpoint == $e) | .SubscriptionArn] | .[]' <<< "$SUBS"; }
attrs() { aws sns get-subscription-attributes --subscription-arn "$1" --query Attributes --output json 2>/dev/null; }
# 1. inventory
s=$(sub_of inventory-updates)
if [ -z "$s" ]; then fail "inventory-updates 가 토픽을 구독하고 원본 그대로 받는다 (구독이 없어요)"
elif [ "$(wc -l <<< "$s")" -gt 1 ]; then fail "inventory-updates 가 토픽을 구독하고 원본 그대로 받는다 (구독이 $(wc -l <<< "$s")개라 메시지가 중복돼요)"
else
  a=$(attrs "$s")
  [ "$(jq -r '.RawMessageDelivery' <<< "$a")" = true ] && pass "inventory-updates 가 토픽을 구독하고 원본 그대로 받는다" \
    || fail "inventory-updates 가 토픽을 구독하고 원본 그대로 받는다 (RawMessageDelivery 가 꺼져 있어요)"
  [ -z "$(jq -r '.FilterPolicy // empty' <<< "$a")" ] && pass "inventory-updates 는 모든 이벤트를 받는다 (필터 없음)" \
    || fail "inventory-updates 는 모든 이벤트를 받는다 (필터가 걸려 있어요: $(jq -r .FilterPolicy <<< "$a"))"
fi
# 2. email
s=$(sub_of email-sender)
if [ -z "$s" ]; then fail "email-sender 는 order_paid, order_shipped 만 받는다 (구독이 없어요)"
elif [ "$(wc -l <<< "$s")" -gt 1 ]; then fail "email-sender 는 order_paid, order_shipped 만 받는다 (구독이 $(wc -l <<< "$s")개라 메시지가 중복돼요)"
else
  a=$(attrs "$s")
  fp=$(jq -r '.FilterPolicy // empty' <<< "$a")
  scope=$(jq -r '.FilterPolicyScope // "MessageAttributes"' <<< "$a")
  norm=$(jq -cS '{event_type: (.event_type | sort?)}' <<< "${fp:-null}" 2>/dev/null)
  keys=$(jq -c 'keys' <<< "${fp:-null}" 2>/dev/null)
  if [ -z "$fp" ]; then fail "email-sender 는 order_paid, order_shipped 만 받는다 (필터가 없어서 취소·환불까지 받아요)"
  elif [ "$scope" != MessageAttributes ]; then fail "email-sender 는 order_paid, order_shipped 만 받는다 (필터는 메시지 속성(MessageAttributes) 기준이어야 해요)"
  elif [ "$keys" = '["event_type"]' ] && [ "$norm" = '{"event_type":["order_paid","order_shipped"]}' ]; then pass "email-sender 는 order_paid, order_shipped 만 받는다"
  else fail "email-sender 는 order_paid, order_shipped 만 받는다 (지금 필터: $fp)"; fi
fi
# 3. 큐 정책
policy_ok() { # 큐이름 → SNS(이 토픽)에 SendMessage 허용하는 문장이 있나
  local p; p=$(aws sqs get-queue-attributes --queue-url "$(url "$1")" --attribute-names Policy --query Attributes.Policy --output text 2>/dev/null)
  [ -n "$p" ] && [ "$p" != None ] && jq -e --arg t "$T" --arg q "$(qarn "$1")" '
    [.Statement | if type == "array" then .[] else . end
     | select(.Effect == "Allow")
     | select((.Principal.Service // "" | if type == "array" then index("sns.amazonaws.com") != null else . == "sns.amazonaws.com" end))
     | select([.Action] | flatten | any(. == "sqs:SendMessage" or . == "sqs:*" or . == "SQS:SendMessage"))
     | select([.Resource] | flatten | any(. == $q or . == "*"))
     | select([.Condition // {} | .[] | .["aws:SourceArn"] // empty] | flatten | any(. == $t))
    ] | length > 0' >/dev/null 2>&1 <<< "$p"
}
for q in inventory-updates email-sender; do
  policy_ok $q && pass "$q 큐 정책이 이 토픽의 SNS 메시지를 허용한다" \
    || fail "$q 큐 정책이 이 토픽의 SNS 메시지를 허용한다 (Principal sns.amazonaws.com + sqs:SendMessage + aws:SourceArn 조건)"
done
# 4. analytics
[ "$(sub_of analytics)" = "$(secret_get analytics-sub)" ] && policy_ok analytics \
  && pass "analytics 의 구독과 정책은 그대로다" || fail "analytics 의 구독과 정책은 그대로다"
finish
