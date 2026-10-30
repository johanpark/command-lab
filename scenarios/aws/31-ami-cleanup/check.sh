#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
amis=$(aws ec2 describe-images --owners self --query 'Images[].ImageId' --output text | tr '\t' '\n')
snaps=$(aws ec2 describe-snapshots --owner-ids self --filters Name=tag-key,Values=App --query 'Snapshots[].SnapshotId' --output text | tr '\t' '\n')
lt=$(aws ec2 describe-launch-template-versions --launch-template-name web-lt --query 'LaunchTemplateVersions[].LaunchTemplateData.ImageId' --output text | tr '\t' '\n')
keep=$( { grep -P '\tweb$' $S/amis | sort -t$'\t' -k3 -r | head -3 | cut -f1; grep -F -x -f <(echo "$lt") <(cut -f1 $S/amis); } | sort -u)
has() { grep -qxF "$1" <<< "$2"; }
nm() { grep -F "$1" $S/amis | cut -f3; }
wrong_gone=""; left=""; snap_left=""; snap_gone=""
while IFS=$'\t' read -r a s n app; do
  if [ "$app" = batch ] || has "$a" "$keep"; then
    has "$a" "$amis" || wrong_gone+="$n "
    has "$s" "$snaps" || snap_gone+="$n "
  else
    has "$a" "$amis" && left+="$n "
    has "$s" "$snaps" && snap_left+="$n "
  fi
done < $S/amis
kept=$(for a in $keep; do nm "$a"; done | sort | paste -sd' ')
[ -z "$wrong_gone" ] && pass "남겨야 할 AMI 는 그대로다 ($kept, batch-*)" || fail "남겨야 할 AMI 는 그대로다 (지워짐: ${wrong_gone% })"
[ -z "$left" ] && pass "나머지 web AMI 는 등록 해제했다" || fail "나머지 web AMI 는 등록 해제했다 (남음: ${left% })"
[ -z "$snap_left" ] && pass "등록 해제한 AMI 의 스냅샷까지 지웠다" || fail "등록 해제한 AMI 의 스냅샷까지 지웠다 (스냅샷이 남은 이미지: ${snap_left% })"
[ -z "$snap_gone" ] && pass "남기는 AMI 의 스냅샷은 그대로다" || fail "남기는 AMI 의 스냅샷은 그대로다 (지워짐: ${snap_gone% })"
finish
