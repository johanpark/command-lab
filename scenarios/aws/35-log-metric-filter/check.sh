#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; D=/opt/cmdlab/scenario; N=$(cat $S/errors); T=$(cat $S/topic)
f=$(aws logs describe-metric-filters --log-group-name /shop/api --filter-name-prefix api-errors --output json 2>/dev/null | jq -c '.metricFilters[] | select(.filterName == "api-errors")')
if [ -z "$f" ]; then fail "/shop/api 에 지표 필터 api-errors 가 있다"
else
  pass "/shop/api 에 지표 필터 api-errors 가 있다"
  pat=$(jq -r .filterPattern <<< "$f")
  IFS=$'\t' read -r hit err < <(python3 "$D/pattern_eval.py" "$pat" $S/events.json)
  if [ "$hit" = parse ]; then fail "필터가 level 이 ERROR 인 줄만 센다 (패턴을 이해하지 못했어요: $err)"
  elif [ "$hit" = "$N" ] && [ "$err" = "$N" ]; then pass "필터가 level 이 ERROR 인 줄만 센다 (로그 160줄 중 ${N}줄)"
  elif [ "$err" = "$N" ]; then fail "필터가 level 이 ERROR 인 줄만 센다 (${hit}줄이 걸려요. 에러가 아닌 $((hit - N))줄까지 세고 있어요 — msg 에 ERROR 글자가 있는 INFO 줄)"
  else fail "필터가 level 이 ERROR 인 줄만 센다 (진짜 에러 ${N}줄 중 ${err}줄만 걸려요)"; fi
  t=$(jq -c '.metricTransformations[0] | {metricNamespace, metricName, metricValue, defaultValue: (.defaultValue // null)}' <<< "$f")
  [ "$(jq -r '"\(.metricNamespace)/\(.metricName) \(.metricValue | tonumber + 0) \(if .defaultValue == null then "없음" else .defaultValue + 0 end)"' <<< "$t")" = "Shop/ApiErrors 1 0" ] \
    && pass "지표는 Shop/ApiErrors, 값 1, 기본값 0 이다" || fail "지표는 Shop/ApiErrors, 값 1, 기본값 0 이다 (지금: $t)"
fi
a=$(aws cloudwatch describe-alarms --alarm-names api-errors-high --query 'MetricAlarms[0]' --output json 2>/dev/null)
if [ -z "$a" ] || [ "$a" = null ]; then fail "api-errors-high 알람이 규칙대로 있다 (알람이 없어요)"
else
  bad=$(jq -r --arg t "$T" '[
    (if .Namespace != "Shop" or .MetricName != "ApiErrors" then "지표(Shop/ApiErrors)" else empty end),
    (if .Statistic != "Sum" then "통계(Sum)" else empty end),
    (if .Period != 60 then "기간(60초)" else empty end),
    (if .EvaluationPeriods != 3 then "연속 횟수(3)" else empty end),
    (if .Threshold != 10 then "임계값(10)" else empty end),
    (if .ComparisonOperator != "GreaterThanOrEqualToThreshold" then "비교(10 이상 = GreaterThanOrEqualToThreshold)" else empty end),
    (if (.TreatMissingData // "missing") != "notBreaching" then "데이터 없음 처리(notBreaching)" else empty end),
    (if (.AlarmActions | index($t)) == null then "알림 대상(ops-alerts)" else empty end)
  ] | join(", ")' <<< "$a")
  [ -z "$bad" ] && pass "api-errors-high 알람이 규칙대로 있다" || fail "api-errors-high 알람이 규칙대로 있다 (다른 곳: $bad)"
fi
finish
