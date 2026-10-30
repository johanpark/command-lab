#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
down=""; wrong=""; missed=""; stopped=""
while IFS=$'\t' read -r i n from want; do
  read -r t st < <(aws ec2 describe-instances --instance-ids "$i" --query 'Reservations[0].Instances[0].[InstanceType,State.Name]' --output text)
  [ "$st" = running ] || stopped+="$n($st) "
  if [ "$t" = "$want" ]; then [ "$from" != "$want" ] && down+="$n "
  elif [ "$from" = "$want" ]; then wrong+="$n($from→$t) "
  else missed+="$n($t, 기대 $want) "; fi
done < $S/plan
[ -z "$missed" ] && pass "기준에 맞는 서버를 한 단계 작게 바꿨다 (${down% })" || fail "기준에 맞는 서버를 한 단계 작게 바꿨다 (아직/다르게: ${missed% })"
[ -z "$wrong" ] && pass "기준에 맞지 않는 서버는 그대로다" || fail "기준에 맞지 않는 서버는 그대로다 (바뀜: ${wrong% })"
[ -z "$stopped" ] && pass "모든 서버가 실행 중이다" || fail "모든 서버가 실행 중이다 (${stopped% })"
finish
