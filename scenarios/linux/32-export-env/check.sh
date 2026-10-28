#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/app/started.txt"
expect "run.sh 와 .env 는 수정하지 않았다" md5sum --quiet -c /opt/cmdlab/secret/md5
if [ ! -f "$F" ]; then fail "앱이 시작됐다 (~/app/started.txt 가 없어요)"
else
  pass "앱이 시작됐다"
  expect "APP_ENV=production, LOG_LEVEL=warn 이 전달됐다" bash -c "grep -qx 'APP_ENV=production' '$F' && grep -qx 'LOG_LEVEL=warn' '$F'"
  pwsha=$(printf '%s' "$(secret_get pw)" | sha256sum | cut -c1-16)
  expect ".env 의 DB 설정이 그대로 전달됐다" bash -c "grep -qx 'DB_HOST=$(secret_get host)' '$F' && grep -qx 'DB_USER=shop' '$F' && grep -qx 'DB_PASSWORD_SHA=$pwsha' '$F'"
fi
finish
