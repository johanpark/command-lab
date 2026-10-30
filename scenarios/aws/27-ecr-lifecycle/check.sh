#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; D=/opt/cmdlab/scenario
un=$(aws ecr list-images --repository-name shop-api --filter tagStatus=UNTAGGED --query 'length(imageIds)' --output text)
[ "$un" = 0 ] && pass "shop-api 의 태그 없는 이미지를 지금 모두 지웠다" || fail "shop-api 의 태그 없는 이미지를 지금 모두 지웠다 (남음: ${un}개)"
now=$(aws ecr list-images --repository-name shop-api --filter tagStatus=TAGGED --query 'imageIds[].imageTag' --output text | tr '\t' '\n' | sort)
miss=$(cut -f3 $S/images | tr ',' '\n' | grep . | sort | comm -23 - <(echo "$now") | paste -sd' ')
[ -z "$miss" ] && pass "태그 있는 이미지는 지금 지우지 않았다" || fail "태그 있는 이미지는 지금 지우지 않았다 (사라짐: $miss)"
P=$(aws ecr get-lifecycle-policy --repository-name shop-api --query lifecyclePolicyText --output text 2>/dev/null)
if [ -z "$P" ]; then fail "수명 주기 정책이 보관 규칙대로 동작한다 (정책이 없어요)"
elif ! jq . <<< "$P" > $S/policy.json 2>/dev/null; then fail "수명 주기 정책이 보관 규칙대로 동작한다 (JSON 이 아니에요)"
else
  out=$(python3 "$D/ecr_eval.py" $S/policy.json $S/images 2>&1)
  if [ "$(head -1 <<< "$out")" = ok ]; then pass "수명 주기 정책이 보관 규칙대로 동작한다 (설정해 둔 이미지들로 시험해 봤어요)"
  else fail "수명 주기 정책이 보관 규칙대로 동작한다"; tail -n +2 <<< "$out" | sed 's/^/    · /'; fi
fi
[ "$(aws ecr list-images --repository-name shop-web --query 'imageIds[].imageDigest' --output text)" = "$(cat $S/web)" ] \
  && ! aws ecr get-lifecycle-policy --repository-name shop-web >/dev/null 2>&1 \
  && pass "shop-web 은 그대로다" || fail "shop-web 은 그대로다"
finish
