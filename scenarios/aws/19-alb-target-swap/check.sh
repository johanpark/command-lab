#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
TG=$(secret_get tg); P=$(secret_get port); HP=$(secret_get hp); S=/opt/cmdlab/secret
T=$(aws elbv2 describe-target-health --target-group-arn "$TG" --query 'TargetHealthDescriptions[].[Target.Id,Target.Port]' --output text 2>/dev/null | sort)
v2ok=1; while read -r i; do grep -qP "^$i\t$P$" <<< "$T" || v2ok=0; done < $S/v2
if [ $v2ok = 1 ]; then pass "실행 중인 v2 서버들이 ${P} 포트로 등록돼 있다"
elif grep -qF -f $S/v2 <<< "$T"; then fail "실행 중인 v2 서버들이 ${P} 포트로 등록돼 있다 (등록은 됐는데 포트가 달라요: $(grep -F -f $S/v2 <<< "$T" | awk '{print $2}' | sort -u | paste -sd' '))"
else fail "실행 중인 v2 서버들이 ${P} 포트로 등록돼 있다"; fi
left=$(grep -F -f $S/v1 <<< "$T" | awk '{print $1}' | tr '\n' ' ')
[ -z "$left" ] && pass "v1 서버는 대상 그룹에서 빠졌다" || fail "v1 서버는 대상 그룹에서 빠졌다 (남음: ${left% })"
n=$(grep -c . <<< "$T"); want=$(wc -l < $S/v2)
[ "$n" = "$want" ] && pass "대상 그룹에는 v2 서버 ${want}대만 있다" || fail "대상 그룹에는 v2 서버 ${want}대만 있다 (지금 ${n}개 등록)"
hp=$(aws elbv2 describe-target-groups --target-group-arns "$TG" --query 'TargetGroups[0].HealthCheckPath' --output text)
[ "$hp" = "$HP" ] && pass "헬스 체크 경로가 $HP 다" || fail "헬스 체크 경로가 $HP 다 (지금: $hp)"
st=$(aws ec2 describe-instances --instance-ids $(cat $S/v1) --query 'Reservations[].Instances[].State.Name' --output text 2>/dev/null | tr '\t' '\n' | sort -u | paste -sd' ')
[ "$st" = running ] && pass "v1 서버는 켜진 채로 남아 있다 (되돌리기용)" || fail "v1 서버는 켜진 채로 남아 있다 (지금: ${st:-없음})"
finish
