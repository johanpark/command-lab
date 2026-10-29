#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/app/.env"
[ -f "$F" ] || { fail "~/app/.env 가 있다"; finish; }
pass "~/app/.env 가 있다"
got=$(tr -d '\r' < "$F" | sed -e 's/^export //' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^#/d' -e '/^$/d' | sed -E 's/^([^=]*)="(.*)"$/\1=\2/' | sort)
want=$(cat /opt/cmdlab/secret/expected)
if grep -q 'kms:alias' <<< "$got"; then fail "SecureString 값이 풀린 실제 값이다 (kms:alias/... 가 보여요 — --with-decryption)"
else pass "SecureString 값이 풀린 실제 값이다"; fi
dup=$(cut -d= -f1 <<< "$got" | uniq -d | tr '\n' ' ')
extra=$(comm -13 <(cut -d= -f1 <<< "$want") <(cut -d= -f1 <<< "$got" | sort -u) | tr '\n' ' ')
[ -n "$dup" ] && extra="${extra}같은 이름이 여러 번: $dup(다른 환경·서비스 값이 섞였어요) "
missing=$(comm -23 <(cut -d= -f1 <<< "$want") <(cut -d= -f1 <<< "$got") | tr '\n' ' ')
[ -z "$extra$missing" ] && pass "/prod/shop/ 의 파라미터가 빠짐없이, 다른 것 없이 들어 있다 (대문자 이름)" \
  || fail "/prod/shop/ 의 파라미터가 빠짐없이, 다른 것 없이 들어 있다${missing:+ (빠짐: $missing)}${extra:+ (있으면 안 됨: $extra)}"
[ "$got" = "$want" ] && pass "모든 값이 운영(prod) 값과 정확히 같다" || fail "모든 값이 운영(prod) 값과 정확히 같다 (staging 값이 섞였거나 값이 달라요)"
finish
