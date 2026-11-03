# 설명: 'true' 를 따옴표로 넣으면 불리언이 아니라 문자열이 된다
# 실패해야: true(불리언)
$j = Get-Content ~/app/appsettings.json -Raw | ConvertFrom-Json
$j.Logging.LogLevel.Default = 'Warning'
$j.Features.NewCheckout = 'true'
$redis = (Select-String -Path ~/request.txt -Pattern '\S+:6379').Matches[0].Value
$j.ConnectionStrings | Add-Member -NotePropertyName Redis -NotePropertyValue $redis
$j | ConvertTo-Json -Depth 10 | Set-Content ~/app/appsettings.json
