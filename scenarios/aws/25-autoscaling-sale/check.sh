#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
N=$(secret_get n); X=$(secret_get x); C=$(secret_get c); E=$(secret_get e)
g=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-asg --query 'AutoScalingGroups[0].[MinSize,DesiredCapacity,MaxSize]' --output text | tr '\t' '/')
[ "$g" = "$N/$N/$X" ] && pass "web-asg 가 최소 $N / 원하는 $N / 최대 $X 다" || fail "web-asg 가 최소 $N / 원하는 $N / 최대 $X 다 (지금 $g)"
p=$(aws autoscaling describe-policies --auto-scaling-group-name web-asg --policy-names cpu-target --query 'ScalingPolicies[0]' --output json 2>/dev/null)
if [ -z "$p" ] || [ "$p" = null ]; then fail "cpu-target 이 평균 CPU ${C}% 대상 추적 정책이다 (정책이 없어요)"
else
  t=$(jq -r '.PolicyType' <<< "$p"); m=$(jq -r '.TargetTrackingConfiguration.PredefinedMetricSpecification.PredefinedMetricType // empty' <<< "$p")
  v=$(jq -r '.TargetTrackingConfiguration.TargetValue // empty | floor' <<< "$p")
  if [ "$t" != TargetTrackingScaling ]; then fail "cpu-target 이 평균 CPU ${C}% 대상 추적 정책이다 (정책 종류: $t)"
  elif [ "$m" != ASGAverageCPUUtilization ]; then fail "cpu-target 이 평균 CPU ${C}% 대상 추적 정책이다 (지표: ${m:-없음}, ASGAverageCPUUtilization 이어야 해요)"
  elif [ "$v" != "$C" ]; then fail "cpu-target 이 평균 CPU ${C}% 대상 추적 정책이다 (목표값: ${v:-없음})"
  else pass "cpu-target 이 평균 CPU ${C}% 대상 추적 정책이다"; fi
fi
a=$(aws autoscaling describe-scheduled-actions --auto-scaling-group-name web-asg --scheduled-action-names after-sale --query 'ScheduledUpdateGroupActions[0]' --output json 2>/dev/null)
if [ -z "$a" ] || [ "$a" = null ]; then fail "after-sale 이 한국 시간 2026-11-12 $E:00 에 2/2/4 로 줄인다 (예약 작업이 없어요)"
else
  sz=$(jq -r '"\(.MinSize)/\(.DesiredCapacity)/\(.MaxSize)"' <<< "$a")
  utc=$(python3 - "$a" <<'PY'
import json, sys
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
a = json.loads(sys.argv[1]); s = a['StartTime'].replace('Z', '+00:00')
t = datetime.fromisoformat(s)
tz = a.get('TimeZone')
if tz:  # 시간대를 준 경우 StartTime 은 그 지역 시각
    t = t.replace(tzinfo=ZoneInfo(tz))
print(t.astimezone(timezone.utc).strftime('%Y-%m-%dT%H:%M'))
PY
)
  want=$(date -u -d "2026-11-12 $E:00 +0900" +%Y-%m-%dT%H:%M)
  kst=$(date -d "${utc}Z" +'%m-%d %H:%M' 2>/dev/null)
  if [ "$utc" != "$want" ]; then
    hint=""; [ "$utc" = "2026-11-12T$E:00" ] && hint=" — 한국 시간을 UTC 로 넣었어요"
    fail "after-sale 이 한국 시간 2026-11-12 $E:00 에 2/2/4 로 줄인다 (지금은 한국 시간 $kst 에 실행돼요$hint)"
  elif [ "$sz" != 2/2/4 ]; then fail "after-sale 이 한국 시간 2026-11-12 $E:00 에 2/2/4 로 줄인다 (크기: $sz)"
  else pass "after-sale 이 한국 시간 2026-11-12 $E:00 에 2/2/4 로 줄인다"; fi
fi
[ "$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names batch-asg --query 'AutoScalingGroups[0].[MinSize,MaxSize,DesiredCapacity]' --output text)" = "$(cat /opt/cmdlab/secret/batch)" ] \
  && pass "batch-asg 는 그대로다" || fail "batch-asg 는 그대로다"
finish
