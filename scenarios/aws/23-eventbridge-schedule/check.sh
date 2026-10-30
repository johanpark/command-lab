#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
D=/opt/cmdlab/scenario; M=$(secret_get min)
rule() { aws events describe-rule --name "$1" --query "$2" --output text 2>/dev/null; }
targets() { aws events list-targets-by-rule --rule "$1" --query 'Targets[].Arn' --output text 2>/dev/null; }
Q=arn:aws:sqs:ap-northeast-2:123456789012
IFS=$'\t' read -r r msg < <(python3 "$D/cron_eval.py" cleanup "$(rule log-cleanup ScheduleExpression)")
[ "$r" = ok ] && pass "log-cleanup 이 한국 시간 매일 04:00 에 돈다" || fail "log-cleanup 이 한국 시간 매일 04:00 에 돈다 ($msg)"
[ "$(targets log-cleanup)" = "$Q:log-cleanup-jobs" ] && pass "log-cleanup 의 대상은 그대로다" || fail "log-cleanup 의 대상은 그대로다"
e=$(rule nightly-sales-report ScheduleExpression)
if [ -z "$e" ]; then fail "nightly-sales-report 가 한국 시간 평일 03:$M 에 돈다 (규칙이 없어요)"
else
  IFS=$'\t' read -r r msg < <(python3 "$D/cron_eval.py" report "$e" "$M")
  [ "$r" = ok ] && pass "nightly-sales-report 가 한국 시간 평일 03:$M 에 돈다" || fail "nightly-sales-report 가 한국 시간 평일 03:$M 에 돈다 ($msg)"
fi
[ "$(rule nightly-sales-report State)" = ENABLED ] && [ "$(targets nightly-sales-report)" = "$Q:report-jobs" ] \
  && pass "nightly-sales-report 가 켜져 있고 report-jobs 큐를 깨운다" || fail "nightly-sales-report 가 켜져 있고 report-jobs 큐를 깨운다 (대상: $(targets nightly-sales-report))"
[ "$(rule weekly-invoice ScheduleExpression)" = "cron(0 0 ? * MON *)" ] && [ "$(targets weekly-invoice)" = "$Q:report-jobs" ] \
  && pass "weekly-invoice 는 그대로다" || fail "weekly-invoice 는 그대로다"
finish
