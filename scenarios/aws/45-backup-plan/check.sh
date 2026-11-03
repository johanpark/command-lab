#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
D=/opt/cmdlab/scenario
aws backup list-backup-vaults --query 'BackupVaultList[].BackupVaultName' --output text 2>/dev/null | tr '\t' '\n' | grep -qx shop-vault \
  && pass "shop-vault 볼트가 있다" || fail "shop-vault 볼트가 있다"
PL=$(aws backup list-backup-plans --output json 2>/dev/null)
ids=$(jq -r '.BackupPlansList[] | select(.BackupPlanName == "shop-backup") | .BackupPlanId' <<< "$PL")
n=$(grep -c . <<< "$ids")
if [ "$n" != 1 ]; then fail "shop-backup 계획이 하나 있다 (지금 ${n}개)"; else
  pass "shop-backup 계획이 하나 있다"
  RULES=$(aws backup get-backup-plan --backup-plan-id "$ids" --query BackupPlan.Rules --output json)
  names=$(jq -r '[.[].RuleName] | sort | join(" ")' <<< "$RULES")
  [ "$names" = "daily monthly" ] && pass "규칙은 daily, monthly 두 개다" || fail "규칙은 daily, monthly 두 개다 (지금: ${names:-없음})"
  for k in daily monthly; do
    r=$(jq -c --arg k "$k" 'first(.[] | select(.RuleName == $k)) // empty' <<< "$RULES")
    [ -z "$r" ] && continue
    case $k in daily) when="매일 03:00"; life="35일 보관"; want='shop-vault 60 - 35' ;; monthly) when="매달 1일 03:00"; life="30일 뒤 콜드, 365일 보관"; want='shop-vault 60 30 365' ;; esac
    IFS=$'\t' read -r ok msg < <(python3 "$D/backup_eval.py" "$k" "$r")
    [ "$ok" = ok ] && pass "$k 규칙이 한국 시간 $when 에 돈다" || fail "$k 규칙이 한국 시간 $when 에 돈다 ($msg)"
    got=$(jq -r '"\(.TargetBackupVaultName) \(.StartWindowMinutes) \(.Lifecycle.MoveToColdStorageAfterDays // "-") \(.Lifecycle.DeleteAfterDays // "-")"' <<< "$r")
    if [ "$got" = "$want" ]; then pass "$k: shop-vault 에, 1시간 안에 시작, $life"
    else
      read -r v sw c dd <<< "$got"; why=""
      [ "$v" = shop-vault ] || why+="볼트 $v, "
      [ "$sw" = 60 ] || why+="시작 창 ${sw}분(StartWindowMinutes 60), "
      [ "$c $dd" = "$(cut -d' ' -f3,4 <<< "$want")" ] || why+="콜드 $c일·삭제 $dd일, "
      fail "$k: shop-vault 에, 1시간 안에 시작, $life (다른 곳: ${why%, })"
    fi
  done
fi
lg=$(jq -r --arg i "$(cat /opt/cmdlab/secret/legacy)" '[.BackupPlansList[] | select(.BackupPlanId == $i)] | length' <<< "$PL")
[ "$lg" = 0 ] && pass "옛 계획 legacy-nightly 를 지웠다" || fail "옛 계획 legacy-nightly 를 지웠다"
finish
