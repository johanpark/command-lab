#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
state() { aws ec2 describe-instances --instance-ids $(cat "$1") --query 'Reservations[].Instances[].State.Name' --output text 2>/dev/null | tr '\t' '\n' | sort -u | tr '\n' ' '; }
s=$(state /opt/cmdlab/secret/target)
[ "$s" = "stopped " ] && pass "켜져 있던 dev 서버를 모두 껐다 (KeepRunning=false 포함)" || fail "켜져 있던 dev 서버를 모두 껐다 (지금 상태: $s— KeepRunning=false 도 끄는 대상이에요)"
s=$(state /opt/cmdlab/secret/keep)
[ "$s" = "running " ] && pass "KeepRunning=true 서버는 계속 켜져 있다" || fail "KeepRunning=true 서버는 계속 켜져 있다 (지금 상태: $s)"
s=$(state /opt/cmdlab/secret/prod)
[ "$s" = "running " ] && pass "prod, staging 서버는 그대로 켜져 있다" || fail "prod, staging 서버는 그대로 켜져 있다 (지금 상태: $s— 운영 서버를 껐어요!)"
gone=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=terminated,shutting-down --query 'Reservations[].Instances[].InstanceId' --output text 2>/dev/null)
[ -z "$gone" ] && pass "삭제(terminate)한 서버가 없다" || fail "삭제(terminate)한 서버가 없다 (끄기는 stop 이에요!)"
expect_answer "stopped.txt 에 이번에 끈 서버 수를 적었다 (원래 꺼져 있던 것 제외)" "$(wc -l < /opt/cmdlab/secret/target)" "$H/stopped.txt"
finish
