#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
done=""; left=""; wrong=""
while IFS=$'\t' read -r v n from want size; do
  t=$(aws ec2 describe-volumes --volume-ids "$v" --query 'Volumes[0].VolumeType' --output text 2>/dev/null)
  if [ -z "$t" ]; then wrong+="$n(삭제됨) "; continue; fi
  if [ "$from" != "$want" ]; then [ "$t" = "$want" ] && done+="$n " || left+="$n "
  elif [ "$t" != "$want" ]; then wrong+="$n($from→$t) "; fi
done < $S/plan
[ -z "$left" ] && pass "대상 gp2 볼륨을 모두 gp3 로 바꿨다 (${done% })" || fail "대상 gp2 볼륨을 모두 gp3 로 바꿨다 (아직: ${left% })"
[ -z "$wrong" ] && pass "보류(hold)·io1·이미 gp3 인 볼륨은 그대로다" || fail "보류(hold)·io1·이미 gp3 인 볼륨은 그대로다 (바뀜: ${wrong% })"
got=$(answer "$H/saving.txt" 2>/dev/null | tr -d '$ ,' | head -1)
want=$(secret_get saving)
if [ -z "$got" ]; then fail "~/saving.txt 에 한 달 절감액을 적었다 (파일이 없어요)"
elif python3 -c "import sys; sys.exit(0 if abs(float(sys.argv[1]) - float(sys.argv[2])) < 0.015 else 1)" "$got" "$want" 2>/dev/null; then pass "~/saving.txt 에 한 달 절감액을 적었다 (\$$want)"
else fail "~/saving.txt 에 한 달 절감액을 적었다 (지금: '$got' — 바꾼 볼륨 크기 합계 × (0.114 - 0.0912))"; fi
finish
