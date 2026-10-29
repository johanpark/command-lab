#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
aws dynamodb create-table --table-name orders \
  --attribute-definitions AttributeName=customer_id,AttributeType=S AttributeName=order_id,AttributeType=S \
  --key-schema AttributeName=customer_id,KeyType=HASH AttributeName=order_id,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST >/dev/null
hex() { printf '%04X' $((RANDOM % 65536)); }
day() { date -d "2026-08-01 + $1 days" +%F; }
item() { # 고객 날짜 상태
  jq -cn --arg c "$1" --arg o "$2#$(hex)" --arg s "$3" --arg t "$(( $(rand_int 12 400) * 100 ))" --arg n "$(rand_int 1 6)" \
    '{PutRequest: {Item: {customer_id: {S: $c}, order_id: {S: $o}, status: {S: $s}, total: {N: $t}, item_count: {N: $n}}}}'
}
T=C-10$(rand_int 10 99); secret_set customer "$T"
: > $S/items
# 다른 고객들 (몇몇은 10월 28일 주문이 있어 "전체에서 가장 최근" 을 고르면 틀림)
for c in C-1003 C-1007 C-1019 C-1101 C-2040 C-0$(rand_int 100 999); do
  [ "$c" = "$T" ] && continue
  for _ in $(seq "$(rand_int 3 8)"); do
    item "$c" "$(day "$(rand_int 0 88)")" "$(rand_pick DELIVERED DELIVERED SHIPPED CANCELLED PAID)" >> $S/items
  done
done
item C-1101 2026-10-28 PAID >> $S/items
# 대상 고객: 8~9월 주문, 9월 30일 주문(경계), 10월 주문 k 개, 그리고 가장 최근(10월 26일) PAID 주문
for _ in $(seq "$(rand_int 2 4)"); do item "$T" "$(day "$(rand_int 0 55)")" DELIVERED >> $S/items; done
item "$T" 2026-09-30 DELIVERED >> $S/items
k=$(rand_int 2 5)
for _ in $(seq "$k"); do item "$T" "2026-10-$(printf %02d "$(rand_int 1 24)")" "$(rand_pick DELIVERED SHIPPED CANCELLED)" >> $S/items; done
last=$(item "$T" 2026-10-26 PAID); echo "$last" >> $S/items
secret_set oct "$((k + 1))"
secret_set last "$(jq -r .PutRequest.Item.order_id.S <<< "$last")"
shuf $S/items | split -l 25 - $S/batch-
for f in $S/batch-*; do
  jq -cs '{orders: .}' "$f" > "$f.json"
  aws dynamodb batch-write-item --request-items "file://$f.json" >/dev/null
done
rm -f $S/batch-*
aws dynamodb scan --table-name orders --output json | jq -c '.Items | sort_by(.customer_id.S, .order_id.S) | .[]' > $S/snapshot
mkdir -p "$H"; printf '고객번호: %s\n문의: 10월 주문 내역 확인, 최근 주문 환불 요청\n' "$T" > "$H/ticket.txt"; give "$H/ticket.txt"
