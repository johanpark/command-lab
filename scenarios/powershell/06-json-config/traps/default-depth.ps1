# 설명: ConvertTo-Json 의 -Depth 를 빼면(기본 2) 깊은 설정이 글자로 뭉개진다
# 실패해야: 깊은 설정
$j = Get-Content ~/app/appsettings.json -Raw | ConvertFrom-Json
$j.Logging.LogLevel.Default = 'Warning'
$j.Features.NewCheckout = $true
$redis = (Select-String -Path ~/request.txt -Pattern '\S+:6379').Matches[0].Value
$j.ConnectionStrings | Add-Member -NotePropertyName Redis -NotePropertyValue $redis
$j | ConvertTo-Json | Set-Content ~/app/appsettings.json
