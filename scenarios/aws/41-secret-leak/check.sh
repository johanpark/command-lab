#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; OLD=$(secret_get old)
cur=$(aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text 2>/dev/null)
NEW=$(jq -r '.password // empty' <<< "$cur" 2>/dev/null)
if [ -z "$NEW" ]; then fail "prod/shop/db 의 password 를 새 값으로 바꿨다 (JSON 이 아니거나 password 가 없어요)"
elif [ "$NEW" = "$OLD" ]; then fail "prod/shop/db 의 password 를 새 값으로 바꿨다 (아직 노출된 옛 비밀번호예요)"
else pass "prod/shop/db 의 password 를 새 값으로 바꿨다"; fi
if [ -n "$NEW" ] && [ "$NEW" != "$OLD" ]; then
  if [ "${#NEW}" -ge 32 ] && [[ "$NEW" =~ ^[A-Za-z0-9]+$ ]]; then pass "새 비밀번호가 32자 이상, 특수문자 없음이다"
  else fail "새 비밀번호가 32자 이상, 특수문자 없음이다 (지금 ${#NEW}자 — get-random-password --password-length 32 --exclude-punctuation)"; fi
fi
same=$(jq -cS 'del(.password)' <<< "$cur" 2>/dev/null); orig=$(jq -cS 'del(.password)' $S/orig.json)
[ "$same" = "$orig" ] && pass "host·port·username 등 다른 값은 그대로다" || fail "host·port·username 등 다른 값은 그대로다 (지금: ${same:-JSON 아님})"
prev=$(aws secretsmanager get-secret-value --secret-id prod/shop/db --version-stage AWSPREVIOUS --query SecretString --output text 2>/dev/null | jq -r .password 2>/dev/null)
[ "$prev" = "$OLD" ] && pass "옛 값은 AWSPREVIOUS 버전에 남아 있다" || fail "옛 값은 AWSPREVIOUS 버전에 남아 있다 (put-secret-value 를 여러 번 했나요? 지금 AWSPREVIOUS: ${prev:+다른 값})"
# RDS 의 실제 마스터 비밀번호는 API 로 볼 수 없어서, 가짜 AWS 의 내부 상태(moto-api)로 확인한다
dbpw=$(curl -s "$AWS_ENDPOINT_URL/moto-api/data.json" | jq -r 'first(.rds.DBInstance[] | select(.db_instance_identifier == "shop-db") | .master_user_password)')  # 같은 DB 가 두 번 나올 수 있다
if [ -n "$NEW" ] && [ "$dbpw" = "$NEW" ]; then pass "shop-db 의 마스터 비밀번호가 새 비밀번호와 같다"
elif [ "$dbpw" = "$OLD" ]; then fail "shop-db 의 마스터 비밀번호가 새 비밀번호와 같다 (DB 는 아직 노출된 옛 비밀번호예요)"
else fail "shop-db 의 마스터 비밀번호가 새 비밀번호와 같다 (DB 와 비밀 값이 달라요 — 앱이 접속을 못 해요)"; fi
[ "$(aws secretsmanager get-secret-value --secret-id prod/report/db --query SecretString --output text)" = "$(cat $S/report)" ] \
  && pass "prod/report/db 는 그대로다" || fail "prod/report/db 는 그대로다"
finish
