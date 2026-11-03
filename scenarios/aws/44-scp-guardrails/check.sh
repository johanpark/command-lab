#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; D=/opt/cmdlab/scenario
R=$(cat $S/root); PROD=$(cat $S/prod); SBX=$(cat $S/sbx); PA=$(cat $S/prod-acct); SA=$(head -1 $S/sbx-accts)
docs() { # 대상에 연결된 SCP 문서들 (JSON 배열)
  aws organizations list-policies-for-target --target-id "$1" --filter SERVICE_CONTROL_POLICY --query 'Policies[].Id' --output text 2>/dev/null \
    | tr '\t' '\n' | grep . | while read -r p; do aws organizations describe-policy --policy-id "$p" --query Policy.Content --output text; done | jq -s -c .
}
names() { aws organizations list-policies-for-target --target-id "$1" --filter SERVICE_CONTROL_POLICY --query 'Policies[].Name' --output text 2>/dev/null | tr '\t' '\n' | sort | paste -sd' '; }
G=$(aws organizations list-policies --filter SERVICE_CONTROL_POLICY --query "Policies[?Name=='sandbox-guardrails'].Id | [0]" --output text 2>/dev/null)
if [ -z "$G" ] || [ "$G" = None ]; then fail "sandbox-guardrails SCP 가 있다"; finish; fi
pass "sandbox-guardrails SCP 가 있다"
tg=$(aws organizations list-targets-for-policy --policy-id "$G" --query 'Targets[].Name' --output text | tr '\t' '\n' | sort | paste -sd' ')
[ "$tg" = Sandbox ] && pass "sandbox-guardrails 는 Sandbox OU 에만 연결돼 있다" || fail "sandbox-guardrails 는 Sandbox OU 에만 연결돼 있다 (지금 연결된 곳: ${tg:-없음})"
miss=""; for t in "$R:Root" "$PROD:Production" "$SBX:Sandbox"; do names "${t%%:*}" | grep -qw FullAWSAccess || miss+="${t#*:} "; done
[ -z "$miss" ] && pass "FullAWSAccess 는 그대로 붙어 있다" || fail "FullAWSAccess 는 그대로 붙어 있다 (떨어진 곳: ${miss% } — SCP 는 허용 목록이라 떼면 그 아래가 전부 막혀요)"
names "$R" | grep -qw deny-leave-org && pass "deny-leave-org 는 루트에 그대로 있다" || fail "deny-leave-org 는 루트에 그대로 있다"
# 실제로 요청을 흉내 내서 평가: Sandbox 계정 = 루트·Sandbox OU·계정, 운영 계정 = 루트·Production OU·계정
L=$(jq -n -c --argjson r "$(docs "$R")" --argjson s "$(docs "$SBX")" --argjson sa "$(docs "$SA")" --argjson p "$(docs "$PROD")" --argjson pa "$(docs "$PA")" \
  '{sbx: [$r, $s, $sa], prod: [$r, $p, $pa]}')
CASES='[
 ["sbx:region1","ec2:RunInstances","us-east-1","t3.micro"], ["sbx:region2","s3:CreateBucket","eu-west-1",null], ["sbx:region3","lambda:CreateFunction","us-west-2",null],
 ["sbx:global1","iam:CreateRole","us-east-1",null], ["sbx:global2","sts:AssumeRole","us-east-1",null], ["sbx:global3","route53:ChangeResourceRecordSets","us-east-1",null], ["sbx:global4","cloudfront:CreateDistribution","us-east-1",null],
 ["sbx:seoul1","ec2:RunInstances","ap-northeast-2","t3.micro"], ["sbx:seoul2","s3:PutObject","ap-northeast-2",null], ["sbx:seoul3","ec2:DescribeInstances","ap-northeast-2",null],
 ["sbx:gpu1","ec2:RunInstances","ap-northeast-2","p3.8xlarge"], ["sbx:gpu2","ec2:RunInstances","ap-northeast-2","g5.xlarge"], ["sbx:gpu3","ec2:RunInstances","ap-northeast-2","g4dn.xlarge"],
 ["sbx:grav1","ec2:RunInstances","ap-northeast-2","m7g.large"], ["sbx:grav2","ec2:RunInstances","ap-northeast-2","c6g.xlarge"],
 ["prod:p1","ec2:RunInstances","us-east-1","t3.micro"], ["prod:p2","ec2:RunInstances","ap-northeast-2","p4d.24xlarge"], ["prod:p3","s3:CreateBucket","eu-west-1",null]
]'
OUT=$(jq -n -c --argjson l "$L" --argjson c "$CASES" '{levels: $l, cases: $c}' | python3 "$D/scp_eval.py")
if grep -q '^ERR' <<< "$OUT"; then fail "정책을 평가할 수 있다 ($(grep '^ERR' <<< "$OUT" | cut -f2))"; finish; fi
get() { awk -F'\t' -v k="$1" '$1 == k { print $2 }' <<< "$OUT"; }
group() { # 제목 기대값 설명 케이스...
  local title=$1 want=$2 desc=$3 bad=""; shift 3
  for c in "$@"; do [ "$(get "$c")" = "$want" ] || bad+="$(jq -r --arg c "$c" '.[] | select(.[0] == $c) | "\(.[1]) @\(.[2])\(if .[3] then " (\(.[3]))" else "" end)"' <<< "$CASES"), "; done
  [ -z "$bad" ] && pass "$title" || fail "$title ($desc: ${bad%, })"
}
group "Sandbox 계정은 서울 밖 리전을 못 쓴다" deny "아직 되는 요청" sbx:region1 sbx:region2 sbx:region3
group "전역 서비스(iam·sts·route53·cloudfront)는 막지 않는다" allow "막혀 버린 요청" sbx:global1 sbx:global2 sbx:global3 sbx:global4
group "서울에서 하는 평범한 작업은 된다" allow "막혀 버린 요청" sbx:seoul1 sbx:seoul2 sbx:seoul3
group "GPU(p·g 계열) 인스턴스는 서울에서도 못 켠다" deny "아직 되는 요청" sbx:gpu1 sbx:gpu2 sbx:gpu3
group "Graviton(m7g·c6g)은 막지 않는다" allow "막혀 버린 요청" sbx:grav1 sbx:grav2
group "운영 계정(Production)은 영향을 받지 않는다" allow "막혀 버린 요청" prod:p1 prod:p2 prod:p3
finish
