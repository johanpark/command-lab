#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
got=$(pwsh -NoLogo -NoProfile -NonInteractive -File /opt/cmdlab/secret/read.ps1 "$H/app/appsettings.json" 2>/dev/null)
orig=$(cat /opt/cmdlab/secret/orig)
v() { grep "^$1=" <<< "$2" | cut -d= -f2-; }
if [ "$got" = INVALID ] || [ -z "$got" ]; then fail "appsettings.json 이 올바른 JSON 이다"; finish; fi
pass "appsettings.json 이 올바른 JSON 이다"
expect "Logging.LogLevel.Default 가 Warning 이다" test "$(v Default "$got")" = Warning
nc=$(v NewCheckout "$got")
[ "$nc" = True/Boolean ] && pass "Features.NewCheckout 이 true(불리언)다" || fail "Features.NewCheckout 이 true(불리언)다 (지금: ${nc%/*} ${nc#*/} — 'true' 문자열이 아니라 \$true)"
expect "ConnectionStrings.Redis 가 요청한 값이다" test "$(v Redis "$got")" = "$(secret_get redis)"
if [ "$(v Provider "$got")" = "$(v Provider "$orig")" ]; then pass "깊은 설정(Recommendations.Provider.Retry)이 그대로다"
else fail "깊은 설정(Recommendations.Provider.Retry)이 그대로다 (ConvertTo-Json 의 -Depth 를 확인하세요)"; fi
same=1; for k in Microsoft Main AllowedHosts; do [ "$(v $k "$got")" = "$(v $k "$orig")" ] || same=0; done
[ "$same" = 1 ] && pass "나머지 설정은 그대로다" || fail "나머지 설정은 그대로다"
finish
