#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
K="$H/Downloads/shop-prod.pem"; DNS=ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
mode=$(stat -c %a "$K" 2>/dev/null)
[ -n "$mode" ] && [ $(( 8#$mode & 8#077 )) -eq 0 ] && pass "키 파일을 나만 읽을 수 있다 ($mode)" || fail "키 파일을 나만 읽을 수 있다 (지금: ${mode:-없음} — chmod 400)"
expect_answer "answer.txt 에 서버의 ~/app/RELEASE 내용을 적었다" "$(secret_get release)"
G() { as_learner ssh -G shop-prod 2>/dev/null | awk -v k="$1" '$1 == k { print $2; exit }'; }
got="$(G hostname) $(G user) $(G identityfile | sed "s|^$H|~|")"
[ "$got" = "$DNS ec2-user ~/Downloads/shop-prod.pem" ] && pass "~/.ssh/config 에 shop-prod 별칭이 있다 (주소, ec2-user, 키 파일)" \
  || fail "~/.ssh/config 에 shop-prod 별칭이 있다 (ssh -G shop-prod: '$got')"
out=$(as_learner ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 shop-prod 'whoami' 2>&1 | tail -n 1)
[ "$out" = ec2-user ] && pass "ssh shop-prod 만으로 서버에 접속된다" || fail "ssh shop-prod 만으로 서버에 접속된다 ($out)"
finish
