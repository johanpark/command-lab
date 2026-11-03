#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
T=$(secret_get topic); S=/opt/cmdlab/secret
subs=$(aws sns list-subscriptions-by-topic --topic-arn "$T" --query "Subscriptions[].[Protocol,Endpoint]" --output text 2>/dev/null)
grep -qP '^email\toncall@shop\.example$' <<< "$subs" && pass "ops-alerts 에 oncall@shop.example 이 email 로 구독돼 있다" \
  || fail "ops-alerts 에 oncall@shop.example 이 email 로 구독돼 있다${subs:+ (지금: $(echo $subs))}"
A=$(aws cloudwatch describe-alarms --output json 2>/dev/null)
while read -r id n; do
  a=$(jq -c --arg n "cpu-high-$n" '.MetricAlarms[] | select(.AlarmName == $n)' <<< "$A")
  if [ -z "$a" ]; then fail "cpu-high-$n 알람이 규칙대로 있다 (알람이 없어요)"; continue; fi
  bad=$(jq -r --arg id "$id" --arg t "$T" '[
    (if .Namespace != "AWS/EC2" or .MetricName != "CPUUtilization" then "지표(AWS/EC2 CPUUtilization)" else empty end),
    (if (.Dimensions | map(select(.Name == "InstanceId")) | .[0].Value) != $id then "차원(InstanceId=\($id))" else empty end),
    (if .Statistic != "Average" then "통계(Average)" else empty end),
    (if .Period != 300 then "기간(300초)" else empty end),
    (if .EvaluationPeriods != 2 or (.DatapointsToAlarm // .EvaluationPeriods) != .EvaluationPeriods then "연속 횟수(2번 중 2번 = evaluation-periods 2, datapoints-to-alarm 은 빼거나 2)" else empty end),
    (if .Threshold != 80 then "임계값(80)" else empty end),
    (if .ComparisonOperator != "GreaterThanThreshold" then "비교(GreaterThanThreshold)" else empty end),
    (if (.AlarmActions | index($t)) == null then "알림 대상(ops-alerts)" else empty end),
    (if .ActionsEnabled == false then "알림 꺼짐(--no-actions-enabled 면 울려도 알림이 안 가요 → --actions-enabled)" else empty end)
  ] | join(", ")' <<< "$a")
  [ -z "$bad" ] && pass "cpu-high-$n 알람이 규칙대로 있다" || fail "cpu-high-$n 알람이 규칙대로 있다 (다른 곳: $bad)"
done < $S/prod
others=$(cut -d' ' -f1 $S/other $S/db | tr '\n' ' ')
extra=$(jq -r --arg o "$others" '.MetricAlarms[] | select(.MetricName == "CPUUtilization") | select(any(.Dimensions[]; .Name == "InstanceId" and (.Value as $v | $o | split(" ") | index($v)))) | .AlarmName' <<< "$A" | grep -v '^cpu-high-old$' | tr '\n' ' ')
[ -z "$extra" ] && pass "규칙 밖 서버(dev·staging·종료됨·Team=db)에는 CPU 알람을 만들지 않았다" || fail "규칙 밖 서버(dev·staging·종료됨·Team=db)에는 CPU 알람을 만들지 않았다 (${extra% })"
jq -e '.MetricAlarms[] | select(.AlarmName == "cpu-high-old")' <<< "$A" >/dev/null \
  && fail "알림 갈 곳이 없는 옛 알람(cpu-high-old)을 지웠다" || pass "알림 갈 곳이 없는 옛 알람(cpu-high-old)을 지웠다"
jq -e '.MetricAlarms[] | select(.AlarmName == "disk-full-prod-db-1")' <<< "$A" >/dev/null \
  && pass "다른 알람(disk-full-prod-db-1)은 그대로다" || fail "다른 알람(disk-full-prod-db-1)은 그대로다 (지워졌어요)"
finish
