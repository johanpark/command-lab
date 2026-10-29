#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
url() { aws sqs get-queue-url --queue-name "$1" --query QueueUrl --output text 2>/dev/null; }
count() { aws sqs get-queue-attributes --queue-url "$1" --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible \
  --query 'Attributes.[ApproximateNumberOfMessages,ApproximateNumberOfMessagesNotVisible]' --output text | awk '{print $1 + $2}'; }
norm() { jq -cS . 2>/dev/null | sort; }
O=$(url orders); D=$(url orders-dlq)
# orders 큐에 들어간 본문 (잠깐 숨겨진 것 포함해 세고, 내용은 보이는 것만 훑는다)
bodies=$(for _ in 1 2 3; do aws sqs receive-message --queue-url "$O" --max-number-of-messages 10 --visibility-timeout 0 \
  --query 'Messages[].Body' --output json 2>/dev/null | jq -r '.[]?'; done | norm | uniq)
n=$(count "$O"); want=$(wc -l < $S/retry)
if [ "$bodies" = "$(norm < $S/retry)" ] && [ "$n" = "$want" ]; then pass "PaymentGatewayTimeout 메시지 ${want}개를 orders 큐로 다시 보냈다"
elif [ "$n" -gt "$want" ]; then fail "PaymentGatewayTimeout 메시지 ${want}개를 orders 큐로 다시 보냈다 (orders 에 ${n}개: 중복이나 InvalidOrder 가 섞였어요)"
else fail "PaymentGatewayTimeout 메시지 ${want}개를 orders 큐로 다시 보냈다 (orders 에 ${n}개)"; fi
if grep -qF -- '"amount":-1' <<< "$bodies"; then fail "InvalidOrder 메시지는 다시 넣지 않았다"; else pass "InvalidOrder 메시지는 다시 넣지 않았다"; fi
f="$H/invalid-orders.jsonl"
if [ ! -f "$f" ]; then fail "~/invalid-orders.jsonl 에 InvalidOrder 본문을 한 줄에 하나씩 저장했다 (파일이 없어요)"
elif [ "$(grep -cv '^\s*$' "$f")" = "$(wc -l < $S/invalid)" ] && [ "$(grep -v '^\s*$' "$f" | norm)" = "$(norm < $S/invalid)" ]; then pass "~/invalid-orders.jsonl 에 InvalidOrder 본문을 한 줄에 하나씩 저장했다"
else fail "~/invalid-orders.jsonl 에 InvalidOrder 본문을 한 줄에 하나씩 저장했다 (내용·줄 수가 달라요. jq -c 로 한 줄씩)"; fi
dn=$(count "$D"); [ "$dn" = 0 ] && pass "orders-dlq 가 비었다" || fail "orders-dlq 가 비었다 (아직 ${dn}개: delete-message 를 했나요?)"
P=$(url payments); PD=$(url payments-dlq)
if [ -z "$PD" ]; then fail "payments 에 payments-dlq 가 5회로 연결돼 있다 (payments-dlq 큐가 없어요)"
else
  parn=$(aws sqs get-queue-attributes --queue-url "$PD" --attribute-names QueueArn --query Attributes.QueueArn --output text)
  rp=$(aws sqs get-queue-attributes --queue-url "$P" --attribute-names RedrivePolicy --query Attributes.RedrivePolicy --output text 2>/dev/null)
  if [ "$(jq -r '.deadLetterTargetArn' <<< "$rp" 2>/dev/null)" = "$parn" ] && [ "$(jq -r '.maxReceiveCount | tostring' <<< "$rp" 2>/dev/null)" = 5 ]; then
    pass "payments 에 payments-dlq 가 5회로 연결돼 있다"
  else fail "payments 에 payments-dlq 가 5회로 연결돼 있다 (지금 RedrivePolicy: ${rp:-없음})"; fi
fi
finish
