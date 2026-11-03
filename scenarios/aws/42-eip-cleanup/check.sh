#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
A=$(aws ec2 describe-addresses --output json 2>/dev/null)
has() { jq -e --arg a "$1" '.Addresses | any(.AllocationId == $a)' <<< "$A" >/dev/null; }
left=""; for a in $(cat $S/free); do has "$a" && left+="$(jq -r --arg a "$a" '.Addresses[] | select(.AllocationId == $a) | (.Tags // [] | map(select(.Key == "Name"))[0].Value // .AllocationId)' <<< "$A") "; done
[ -z "$left" ] && pass "연결 안 된 주소를 반납했다" || fail "연결 안 된 주소를 반납했다 (아직 남은 것: ${left% })"
gone=""; for a in $(cat $S/keep); do has "$a" || gone+="$a "; done
[ -z "$gone" ] && pass "Keep=true 예약 주소는 남겨 뒀다" || fail "Keep=true 예약 주소는 남겨 뒀다 (반납됨: ${gone% } — 반납한 주소는 같은 IP 로 되돌릴 수 없어요. 파트너 방화벽 등록을 다시 해야 해요)"
read -r OA OI < $S/oldbatch
if has "$OA"; then fail "old-batch 의 주소를 떼서 반납했다 (아직 있어요 — 연결된 주소는 disassociate-address 로 먼저 떼야 반납돼요)"
else pass "old-batch 의 주소를 떼서 반납했다"; fi
st=$(aws ec2 describe-instances --instance-ids "$OI" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null)
[ "$st" = stopped ] && pass "old-batch 서버는 그대로다 (꺼진 상태)" || fail "old-batch 서버는 그대로다 (지금: ${st:-없음} — 서버 폐기는 다음 달이에요)"
bad=""; while read -r a i; do
  got=$(jq -r --arg a "$a" '.Addresses[] | select(.AllocationId == $a) | .InstanceId // ""' <<< "$A")
  [ "$got" = "$i" ] || bad+="$a "
done < $S/web
[ -z "$bad" ] && pass "web-1, web-2 의 주소는 그대로 붙어 있다" || fail "web-1, web-2 의 주소는 그대로 붙어 있다 (달라진 주소: ${bad% } — 서비스 주소가 바뀌면 DNS·고객 방화벽이 다 깨져요)"
N=$(cat $S/nat)
nat=$(jq -r --arg a "$N" '.Addresses[] | select(.AllocationId == $a) | .AssociationId // ""' <<< "$A")
[ -n "$nat" ] && pass "NAT 게이트웨이 주소는 그대로다" || fail "NAT 게이트웨이 주소는 그대로다 (없거나 떨어졌어요 — 프라이빗 서버들이 인터넷에 못 나가요)"
new=$(comm -13 $S/all <(jq -r '.Addresses[].AllocationId' <<< "$A" | sort) | paste -sd' ')
[ -z "$new" ] && pass "새 주소를 만들지 않았다" || fail "새 주소를 만들지 않았다 (새로 생긴 것: $new)"
finish
