#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A="$H/app"; mkdir -p "$A"
db="db0$(rand_int 1 9)"; timeout=$(rand_int 2 9)00; retries=$(rand_int 2 5); redis="cache-0$(rand_int 1 9).internal:6379"
secret_set redis "$redis"
cat > "$A/appsettings.json" <<JSON
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft": "Warning",
      "Shop.Payments": "Information"
    }
  },
  "ConnectionStrings": {
    "Main": "Server=$db;Database=shop;User Id=shop_app"
  },
  "Features": {
    "NewCheckout": false,
    "Recommendations": {
      "Enabled": true,
      "Provider": {
        "Name": "simple",
        "TimeoutMs": $timeout,
        "Retry": { "Count": $retries, "BackoffMs": 200 }
      }
    }
  },
  "AllowedHosts": "*"
}
JSON
cat > "$H/request.txt" <<REQ
[배포 전 설정 변경 요청]
- 운영 로그는 Warning 이상만 남겨 주세요 (Logging.LogLevel.Default)
- 새 결제 화면을 켜 주세요 (Features.NewCheckout)
- 캐시 서버 연결 추가: ConnectionStrings.Redis = $redis
REQ
give "$A" "$H/request.txt"
# 채점용: 확인할 값을 한 줄씩 뽑는 스크립트
cat > /opt/cmdlab/secret/read.ps1 <<'PS'
try { $j = Get-Content $args[0] -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop } catch { 'INVALID'; exit }
$p = $j.Features.Recommendations.Provider
"Default=$($j.Logging.LogLevel.Default)"
"NewCheckout=$($j.Features.NewCheckout)/$(if ($null -ne $j.Features.NewCheckout) { $j.Features.NewCheckout.GetType().Name })"
"Redis=$($j.ConnectionStrings.Redis)"
"Microsoft=$($j.Logging.LogLevel.Microsoft)|$($j.Logging.LogLevel.'Shop.Payments')"
"Main=$($j.ConnectionStrings.Main)"
"Provider=$($p.Name)|$($p.TimeoutMs)|$($p.Retry.Count)|$($p.Retry.BackoffMs)|$($j.Features.Recommendations.Enabled)"
"AllowedHosts=$($j.AllowedHosts)"
PS
pwsh -NoLogo -NoProfile -NonInteractive -File /opt/cmdlab/secret/read.ps1 "$A/appsettings.json" > /opt/cmdlab/secret/orig
