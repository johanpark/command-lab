#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
f="$H/expiring.txt"
want=$'old-event.shop.example\nshop.example'
got=$(answer "$f" 2>/dev/null | tr 'A-Z' 'a-z' | sed 's/\.$//' | sort -u)
if [ ! -f "$f" ]; then fail "~/expiring.txt 에 30일 안에 만료되는 도메인을 적었다 (파일이 없어요)"
elif [ "$got" = "$want" ]; then pass "~/expiring.txt 에 30일 안에 만료되는 도메인을 적었다"
else fail "~/expiring.txt 에 30일 안에 만료되는 도메인을 적었다 (지금: $(echo $got))"; fi
SHOP=$(secret_get shop)
info=$(aws acm describe-certificate --certificate-arn "$SHOP" --query 'Certificate.[NotAfter,Serial]' --output text 2>/dev/null)
if [ -z "$info" ]; then fail "shop.example 인증서를 같은 ARN 에서 새 것으로 교체했다 (원래 ARN 의 인증서가 없어요 — 지웠나요?)"
else
  read -r na serial <<< "$info"
  # 일련번호: 실제 AWS 는 콜론으로 나눈 16진수, 이 실습의 가짜 AWS 는 10진수로 준다 → 둘 다 정수로 비교
  ser=$(python3 -c "import sys; s=sys.argv[1]; print(format(int(s.replace(':', ''), 16) if (':' in s or not s.isdigit()) else int(s), 'x'))" "$serial" 2>/dev/null)
  days=$(python3 -c "import sys,time; print(int((float(sys.argv[1]) - time.time()) // 86400))" "$na")
  if [ "$ser" = "$(cat $S/new-serial)" ]; then pass "shop.example 인증서를 같은 ARN 에서 새 것으로 교체했다 (만료까지 ${days}일)"
  elif [ "$days" -lt 30 ]; then fail "shop.example 인증서를 같은 ARN 에서 새 것으로 교체했다 (아직 ${days}일 뒤 만료되는 옛 인증서예요)"
  else fail "shop.example 인증서를 같은 ARN 에서 새 것으로 교체했다 (업체가 보낸 2027 인증서가 아니에요)"; fi
fi
lc=$(aws elbv2 describe-listeners --listener-arns "$(cat $S/listener)" --query 'Listeners[0].Certificates[0].CertificateArn' --output text 2>/dev/null)
[ "$lc" = "$SHOP" ] && pass "운영 리스너(443)는 그대로 같은 인증서 ARN 을 쓴다" || fail "운영 리스너(443)는 그대로 같은 인증서 ARN 을 쓴다 (지금: $lc)"
aws acm describe-certificate --certificate-arn "$(secret_get event)" >/dev/null 2>&1 \
  && fail "안 쓰는 만료 예정 인증서(old-event.shop.example)를 지웠다" || pass "안 쓰는 만료 예정 인증서(old-event.shop.example)를 지웠다"
bad=""; for k in admin partner; do aws acm describe-certificate --certificate-arn "$(secret_get $k)" >/dev/null 2>&1 || bad+="$k.shop.example "; done
[ -z "$bad" ] && pass "다른 인증서(admin, partner)는 그대로다" || fail "다른 인증서(admin, partner)는 그대로다 (지워짐: ${bad% })"
finish
