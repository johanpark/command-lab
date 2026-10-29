#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
now=$(aws dynamodb scan --table-name products --output json 2>/dev/null | jq -c '.Items[]' | jq -cS . | sort)
key() { jq -r '.sku.S' | sort; }
missing=$(comm -23 <(grep -F -f $S/deleted $S/expected | key) <(key <<< "$now") | paste -sd' ')
[ -z "$missing" ] && pass "지워진 상품 $(wc -l < $S/deleted)개를 모두 되살렸다" || fail "지워진 상품 $(wc -l < $S/deleted)개를 모두 되살렸다 (아직 없음: $missing)"
wrongdel=$(grep -F -f $S/deleted $S/expected | while read -r e; do s=$(jq -r .sku.S <<< "$e"); c=$(grep -F "\"$s\"" <<< "$now"); [ -n "$c" ] && [ "$c" != "$e" ] && echo "$s"; done | paste -sd' ')
[ -z "$wrongdel" ] && pass "되살린 상품의 값이 어젯밤 백업과 같다" || fail "되살린 상품의 값이 어젯밤 백업과 같다 (다름: $wrongdel — 그저께 백업을 썼나요?)"
lost=$(grep -F -f $S/changed $S/expected | while read -r e; do grep -qxF "$e" <<< "$now" || jq -r .sku.S <<< "$e"; done | paste -sd' ')
[ -z "$lost" ] && pass "오늘 바꾼 가격 3건이 그대로다" || fail "오늘 바꾼 가격 3건이 그대로다 (어젯밤 값으로 돌아감: $lost)"
grep -q '"P-2001"' <<< "$now" && grep -q '"P-2002"' <<< "$now" && pass "오늘 등록한 신상품 2개가 그대로다" || fail "오늘 등록한 신상품 2개가 그대로다 (사라졌어요!)"
[ "$now" = "$(cat $S/expected)" ] && pass "products 테이블이 정확히 기대한 상태다 ($(wc -l < $S/expected)개)" \
  || { n=$(grep -c . <<< "$now"); w=$(wc -l < $S/expected)
       [ "$n" = "$w" ] && fail "products 테이블이 정확히 기대한 상태다 (개수는 ${n}개로 맞지만 값이 다른 상품이 있어요)" \
                       || fail "products 테이블이 정확히 기대한 상태다 (지금 ${n}개, 기대 ${w}개)"; }
st=$(aws dynamodb describe-continuous-backups --table-name products --query ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus --output text 2>/dev/null)
[ "$st" = ENABLED ] && pass "products 에 시점 복구(PITR)가 켜져 있다" || fail "products 에 시점 복구(PITR)가 켜져 있다 (지금: ${st:-?})"
finish
