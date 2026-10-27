#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/shop/compose.yaml"
expect "compose.yaml 의 web 이미지가 shop-web:1.0 이다" grep -qE '^\s*image:\s*"?shop-web:1\.0"?\s*$' "$F"
running() { docker ps -q --filter label=com.docker.compose.project=shop --filter "label=com.docker.compose.service=$1" --filter status=running | grep -q .; }
expect "compose 의 web 서비스가 실행 중이다" running web
expect "compose 의 api 서비스가 실행 중이다" running api
if curl -fs http://localhost:8080 2>/dev/null | grep -qF "$(secret_get code)"; then pass "http://localhost:8080 이 쇼핑몰 페이지를 보여준다"
else fail "http://localhost:8080 이 쇼핑몰 페이지를 보여준다 (포트는 \"바깥:안\" 순서)"; fi
[ "$(curl -fs http://localhost:3000/health 2>/dev/null)" = ok ] && pass "http://localhost:3000/health 가 ok 다" || fail "http://localhost:3000/health 가 ok 다"
finish
