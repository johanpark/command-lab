#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
dbhost=$(secret_get dbhost); UD=/var/lib/cloud/instance/user-data.txt
expect_answer "answer.txt 에 부팅 스크립트를 멈추게 한 변수 이름을 적었다" DB_HOST
expect "app.env 의 DB_HOST 가 runbook 의 값이다" grep -qx "DB_HOST=$dbhost" /opt/shop/config/app.env
expect "app.env 의 PORT 는 8080 이다" grep -qx 'PORT=8080' /opt/shop/config/app.env
[ "$(curl -fs -m 3 http://localhost:8080/health 2>/dev/null)" = ok ] && pass "http://localhost:8080/health 가 ok 다" || fail "http://localhost:8080/health 가 ok 다 (앱이 안 떠 있어요)"
owner=$(ps -o user= -C busybox 2>/dev/null | sort -u | tr '\n' ' ')
[ "$owner" = "shop " ] && pass "앱이 shop 사용자로 실행 중이다" || fail "앱이 shop 사용자로 실행 중이다 (지금: ${owner:-실행 안 됨})"
expect "/opt/shop 의 소유자가 shop 이다 (남은 단계 chown)" test -z "$(find /opt/shop ! -user shop 2>/dev/null)"
# 고친 user-data 를 새 서버처럼 깨끗한 환경에서 문법 검사 + DB_HOST 없이 실행해 본다
T=$(mktemp -d)
if bash -n "$UD" 2>/dev/null && sed -e "s#/opt/shop#$T/shop#g" -e '/useradd/d' -e '/chown/d' -e '/sudo -u shop/d' "$UD" > "$T/ud.sh" \
   && mkdir -p "$T/shop" && env -u DB_HOST bash "$T/ud.sh" >/dev/null 2>&1 && grep -qx "DB_HOST=$dbhost" "$T/shop/config/app.env"; then
  pass "고친 user-data 는 DB_HOST 를 따로 주지 않아도 끝까지 돈다"
else fail "고친 user-data 는 DB_HOST 를 따로 주지 않아도 끝까지 돈다 (DB_HOST 를 쓰기 전에 값을 정했나요?)"; fi
rm -rf "$T"
finish
