#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect "deploy.sh 에 실행 권한이 있다" test -x "$H/deploy.sh"
if [ "$(cat "$H/deploy-result.txt" 2>/dev/null)" = "deployed $(secret_get token)" ]; then
  pass "deploy.sh 를 실행해서 배포를 완료했다"
else
  fail "deploy.sh 를 실행해서 배포를 완료했다 (~/deploy-result.txt 가 없거나 내용이 달라요)"
fi
mode=$(stat -c '%a' "$H/secrets/api.key" 2>/dev/null)
[ "$mode" = 600 ] && pass "api.key 권한이 600 (-rw-------)" || fail "api.key 권한이 600 (-rw-------) (지금: ${mode:-없음})"
mode=$(stat -c '%a' "$H/secrets" 2>/dev/null)
[ "$mode" = 700 ] && pass "secrets 폴더 권한이 700 (drwx------)" || fail "secrets 폴더 권한이 700 (drwx------) (지금: ${mode:-없음})"
expect "api.key 의 소유자는 여전히 learner" test "$(stat -c %U "$H/secrets/api.key" 2>/dev/null)" = "$LEARNER"
finish
