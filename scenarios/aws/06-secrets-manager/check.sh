#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
A="$H/app"; pw=$(secret_get pw)
val=$(aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text 2>/dev/null)
if [ -z "$val" ]; then fail "Secrets Manager 에 prod/shop/db 가 있다"
else
  pass "Secrets Manager 에 prod/shop/db 가 있다"
  if ! jq -e . >/dev/null 2>&1 <<< "$val"; then fail "값이 username, password 를 가진 JSON 이다 (지금 값이 JSON 이 아니에요)"
  elif [ "$(jq -r .username <<< "$val")" = shop ] && [ "$(jq -r .password <<< "$val")" = "$pw" ]; then pass "값이 username, password 를 가진 JSON 이다"
  else fail "값이 username, password 를 가진 JSON 이다 (username 이 shop 이고 password 가 원래 비밀번호인지 확인)"; fi
fi
if grep -q '^DB_PASSWORD=' "$A/.env" 2>/dev/null; then fail ".env 에서 DB_PASSWORD 줄을 지웠다"
else pass ".env 에서 DB_PASSWORD 줄을 지웠다"; fi
expect ".env 의 다른 설정(DB_HOST, DB_USER, LOG_LEVEL)은 그대로다" test "$(grep -v '^DB_PASSWORD=' "$A/.env" 2>/dev/null)" = "$(cat /opt/cmdlab/secret/env-rest)"
leak=$(grep -rlF -- "$pw" "$A" 2>/dev/null | sed "s#^$H/#~/#" | tr '\n' ' ')
[ -z "$leak" ] && pass "~/app 어디에도 비밀번호가 글자로 남아 있지 않다" || fail "~/app 어디에도 비밀번호가 글자로 남아 있지 않다 (남은 곳: $leak— 백업 파일이나 스크립트에 직접 적지 않았나요?)"
rm -f "$A/started.txt"
out=$(as_learner bash -c "cd '$A' && ./start.sh" 2>&1)
if [ -f "$A/started.txt" ] && grep -q '연결 성공' <<< "$out"; then pass "start.sh 가 Secrets Manager 의 비밀번호로 DB 에 연결된다"
else fail "start.sh 가 Secrets Manager 의 비밀번호로 DB 에 연결된다 ($(tail -n 1 <<< "$out" | cut -c1-100))"; fi
expect "다른 팀의 비밀(prod/batch/api-key)은 그대로다" aws secretsmanager describe-secret --secret-id prod/batch/api-key
finish
