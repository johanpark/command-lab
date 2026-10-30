#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; APP=$(secret_get app); BAS=$(secret_get bas)
rules() { # 그룹 → "포트 출처" 줄들 (출처: sg-.. 또는 CIDR)
  aws ec2 describe-security-groups --group-ids "$1" --output json | jq -r '.SecurityGroups[0].IpPermissions[]
    | "\(.IpProtocol):\(.FromPort)-\(.ToPort) " as $p
    | ([.IpRanges[]?.CidrIp, .Ipv6Ranges[]?.CidrIpv6] | map($p + .)) + [.UserIdGroupPairs[]? | $p + .GroupId] | .[]' | sort
}
name() { case "$1" in "$APP") echo app-sg;; "$BAS") echo bastion-sg;; *) echo "$1";; esac; }
check_sg() { # 이름 그룹ID 포트 허용그룹들...
  local n=$1 g=$2 port=$3; shift 3
  local cur want open extra miss
  cur=$(rules "$g"); want=$(for s in "$@"; do echo "tcp:$port-$port $s"; done | sort)
  open=$(grep -E ' ([0-9.]+/[0-9]+|[0-9a-f:]+/[0-9]+)$' <<< "$cur" | awk '{print $2}' | paste -sd' ')
  miss=$(comm -23 <(echo "$want") <(echo "$cur") | awk '{print $2}' | while read -r x; do name "$x"; done | paste -sd' ')
  extra=$(comm -13 <(echo "$want") <(echo "$cur") | grep . | paste -sd',')
  if [ -n "$open" ]; then fail "$n 는 $(for s in "$@"; do name "$s"; done | paste -sd' ' | sed 's/ / 와 /') 에서만 $port 포트를 허용한다 (아직 IP 대역에 열림: $open)"
  elif [ -n "$miss" ]; then fail "$n 는 $(for s in "$@"; do name "$s"; done | paste -sd' ' | sed 's/ / 와 /') 에서만 $port 포트를 허용한다 (빠짐: $miss)"
  elif [ -n "$extra" ]; then fail "$n 는 $(for s in "$@"; do name "$s"; done | paste -sd' ' | sed 's/ / 와 /') 에서만 $port 포트를 허용한다 (필요 없는 규칙: $extra)"
  else pass "$n 는 $(for s in "$@"; do name "$s"; done | paste -sd' ' | sed 's/ / 와 /') 에서만 $port 포트를 허용한다"; fi
}
check_sg db-sg "$(secret_get db)" 5432 "$APP" "$BAS"
check_sg cache-sg "$(secret_get cache)" 6379 "$APP"
now=$(for g in alb-sg app-sg bastion-sg; do aws ec2 describe-security-groups --filters Name=group-name,Values=$g --query 'SecurityGroups[0].IpPermissions' --output json | jq -cS .; done)
[ "$now" = "$(cat $S/keep)" ] && pass "alb-sg, app-sg, bastion-sg 는 그대로다" || fail "alb-sg, app-sg, bastion-sg 는 그대로다"
finish
