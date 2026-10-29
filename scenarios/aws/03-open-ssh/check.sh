#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
SG=$(secret_get sg); office=$(secret_get office)
# 규칙을 '포트 주소' 한 줄씩으로 펼친다
rules=$(aws ec2 describe-security-groups --group-ids "$SG" --output json 2>/dev/null | jq -r '
  .SecurityGroups[0].IpPermissions[] | (.FromPort | tostring) as $p
  | ((.IpRanges // [])[] | "\($p) \(.CidrIp)"), ((.Ipv6Ranges // [])[] | "\($p) \(.CidrIpv6)")' | sort)
open() { grep -cE "^$1 (0\.0\.0\.0/0|::/0)$" <<< "$rules"; }
n22=$(open 22); n3306=$(open 3306)
v6=$(grep -c '^22 ::/0$' <<< "$rules")
if [ "$n22" = 0 ]; then pass "SSH(22) 가 인터넷 전체에 열려 있지 않다 (IPv4, IPv6 모두)"
elif [ "$v6" = 1 ] && [ "$n22" = 1 ]; then fail "SSH(22) 가 인터넷 전체에 열려 있지 않다 (IPv6 ::/0 규칙이 남아 있어요!)"
else fail "SSH(22) 가 인터넷 전체에 열려 있지 않다 (${n22}개 남음)"; fi
[ "$n3306" = 0 ] && pass "MySQL(3306) 이 인터넷 전체에 열려 있지 않다" || fail "MySQL(3306) 이 인터넷 전체에 열려 있지 않다"
others22=$(grep '^22 ' <<< "$rules" | cut -d' ' -f2 | tr '\n' ' ')
[ "$others22" = "$office/32 " ] && pass "SSH(22) 는 사무실 IP($office/32) 하나만 허용한다" || fail "SSH(22) 는 사무실 IP($office/32) 하나만 허용한다 (지금: ${others22:-없음})"
grep -q '^3306 ' <<< "$rules" && fail "3306 규칙이 아예 없다 (인터넷에서 DB 로 들어올 길이 없어야 해요)" || pass "3306 규칙이 아예 없다"
web=$(grep -cE '^(80|443) (0\.0\.0\.0/0|::/0)$' <<< "$rules")
[ "$web" = 4 ] && pass "웹(80, 443) 은 그대로 전 세계에 열려 있다 (IPv4, IPv6)" || fail "웹(80, 443) 은 그대로 전 세계에 열려 있다 (손님이 못 들어와요! 지금 ${web}/4 규칙)"
expect "다른 보안 그룹(batch-sg)은 그대로다" bash -c "[ \"\$(aws ec2 describe-security-groups --group-ids $(secret_get other) --query 'SecurityGroups[0].IpPermissions' --output json)\" = \"\$(cat /opt/cmdlab/secret/other.json)\" ]"
finish
