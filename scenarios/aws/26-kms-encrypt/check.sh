#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
K=$(aws kms list-aliases --query "Aliases[?AliasName=='alias/payments'].TargetKeyId" --output text 2>/dev/null)
if [ -z "$K" ] || [ "$K" = None ]; then fail "alias/payments 키가 있다"
else
  st=$(aws kms describe-key --key-id "$K" --query KeyMetadata.KeyState --output text)
  [ "$st" = Enabled ] && pass "alias/payments 키가 있다" || fail "alias/payments 키가 있다 (키 상태: $st)"
  case "$K" in "$(secret_get legacy)"|"$(secret_get orders)"|"$(secret_get test)") fail "결제 전용 새 키다 (다른 용도의 기존 키에 별칭을 붙였어요)";; *) pass "결제 전용 새 키다";; esac
  [ "$(aws kms get-key-rotation-status --key-id "$K" --query KeyRotationEnabled --output text)" = True ] \
    && pass "자동 키 교체가 켜져 있다" || fail "자동 키 교체가 켜져 있다"
fi
E="$H/payment-config.json.enc"
if [ ! -s "$E" ]; then fail "payment-config.json.enc 를 alias/payments 키로 풀면 원래 내용이 나온다 (파일이 없어요)"
else
  out=$(aws kms decrypt --ciphertext-blob "fileb://$E" --query '[KeyId,Plaintext]' --output text 2>/dev/null)
  [ -z "$out" ] && out=$(base64 -d "$E" > $S/ct 2>/dev/null && aws kms decrypt --ciphertext-blob "fileb://$S/ct" --query '[KeyId,Plaintext]' --output text 2>/dev/null)
  kid=$(cut -f1 <<< "$out"); pt=$(cut -f2 <<< "$out")
  if [ -z "$out" ]; then fail "payment-config.json.enc 를 alias/payments 키로 풀면 원래 내용이 나온다 (KMS 로 풀리지 않아요)"
  elif [ "$(base64 -d <<< "$pt" | sha256sum | cut -d' ' -f1)" != "$(cat $S/sha)" ]; then fail "payment-config.json.enc 를 alias/payments 키로 풀면 원래 내용이 나온다 (내용이 원본과 달라요)"
  elif [ -n "$K" ] && [ "${kid##*/}" != "$K" ]; then fail "payment-config.json.enc 를 alias/payments 키로 풀면 원래 내용이 나온다 (다른 키로 암호화했어요)"
  else pass "payment-config.json.enc 를 alias/payments 키로 풀면 원래 내용이 나온다"; fi
fi
[ ! -e "$H/payment-config.json" ] && pass "평문 payment-config.json 은 지웠다" || fail "평문 payment-config.json 은 지웠다"
T=$(secret_get test)
read -r ts dd < <(aws kms describe-key --key-id "$T" --query 'KeyMetadata.[KeyState,DeletionDate]' --output text)
days=$(python3 -c "import sys,time; print(round((float(sys.argv[1]) - time.time()) / 86400))" "$dd" 2>/dev/null)
if [ "$ts" != PendingDeletion ]; then fail "테스트 키가 7일 뒤 삭제 예약돼 있다 (지금: $ts)"
elif [ "$days" != 7 ]; then fail "테스트 키가 7일 뒤 삭제 예약돼 있다 (약 ${days}일 뒤로 예약돼 있어요)"
else pass "테스트 키가 7일 뒤 삭제 예약돼 있다"; fi
bad=""; for k in legacy orders; do [ "$(aws kms describe-key --key-id "$(secret_get $k)" --query KeyMetadata.KeyState --output text)" = Enabled ] || bad+="$k "; done
[ -z "$bad" ] && pass "다른 키(legacy-app, 주문 서비스)는 그대로다" || fail "다른 키(legacy-app, 주문 서비스)는 그대로다 (바뀜: ${bad% })"
finish
