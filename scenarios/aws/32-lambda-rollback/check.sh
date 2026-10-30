#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; C=$(secret_get conc)
alias_v() { aws lambda get-alias --function-name order-api --name "$1" --query FunctionVersion --output text 2>/dev/null; }
L=$(alias_v live)
case "$L" in
  2) pass "live 가 장애 직전 정상 버전(2)을 가리킨다" ;;
  3) fail "live 가 장애 직전 정상 버전을 가리킨다 (아직 장애 버전 3)" ;;
  1) fail "live 가 장애 직전 정상 버전을 가리킨다 (1 은 옛 DB(db-1)를 쓰는 버전이에요)" ;;
  *) fail "live 가 장애 직전 정상 버전을 가리킨다 (지금: $L — 새로 고친 버전은 QA 전이라 staging 에만)" ;;
esac
cur=$(aws lambda get-function-configuration --function-name order-api --query Environment.Variables --output json | jq -cS .)
if [ "$cur" = "$(cat $S/want-env)" ]; then pass "\$LATEST 의 DB_HOST 를 고쳤고 다른 환경 변수는 그대로다"
elif [ "$(jq -r .DB_HOST <<< "$cur")" = db-2.internal ]; then fail "\$LATEST 의 DB_HOST 를 고쳤고 다른 환경 변수는 그대로다 (다른 변수가 사라졌거나 바뀌었어요: $(jq -c 'keys' <<< "$cur"))"
else fail "\$LATEST 의 DB_HOST 를 고쳤고 다른 환경 변수는 그대로다 (DB_HOST: $(jq -r .DB_HOST <<< "$cur"))"; fi
SV=$(alias_v staging)
if [ "$SV" -gt 3 ] 2>/dev/null; then
  venv=$(aws lambda get-function-configuration --function-name order-api --qualifier "$SV" --query Environment.Variables --output json | jq -cS .)
  [ "$venv" = "$(cat $S/want-env)" ] && pass "고친 설정으로 새 버전($SV)을 발행하고 staging 이 가리킨다" \
    || fail "고친 설정으로 새 버전을 발행하고 staging 이 가리킨다 (버전 $SV 의 환경 변수가 올바른 설정과 달라요)"
else fail "고친 설정으로 새 버전을 발행하고 staging 이 가리킨다 (staging: ${SV:-없음})"; fi
c=$(aws lambda get-function-concurrency --function-name order-api --query ReservedConcurrentExecutions --output text 2>/dev/null); [ "$c" = None ] && c=""
[ "$c" = "$C" ] && pass "예약 동시 실행이 $C 이다" || fail "예약 동시 실행이 $C 이다 (지금: ${c:-없음})"
finish
