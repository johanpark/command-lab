#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
exists() { aws ec2 describe-volumes --volume-ids "$1" >/dev/null 2>&1; }
left=""; while read -r v; do exists "$v" && left+="$v "; done < /opt/cmdlab/secret/target
[ -z "$left" ] && pass "붙어 있지 않은 볼륨을 모두 지웠다 (Keep=false 포함)" || fail "붙어 있지 않은 볼륨을 모두 지웠다 (남음: ${left% })"
gone=""; while read -r v; do exists "$v" || gone+="$v "; done < /opt/cmdlab/secret/keep
[ -z "$gone" ] && pass "Keep=true 볼륨은 남아 있다" || fail "Keep=true 볼륨은 남아 있다 (DB 복구 디스크를 지웠어요!)"
gone=""; while read -r v; do exists "$v" || gone+="$v "; done < /opt/cmdlab/secret/inuse
[ -z "$gone" ] && pass "서버에 붙은(in-use) 볼륨은 그대로다" || fail "서버에 붙은(in-use) 볼륨은 그대로다 (지워졌어요!)"
expect_answer "freed.txt 에 지운 볼륨 용량 합계(GiB)를 적었다" "$(secret_get freed)" "$H/freed.txt"
finish
