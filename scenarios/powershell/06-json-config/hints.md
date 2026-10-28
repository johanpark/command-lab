`$j = Get-Content ~/app/appsettings.json -Raw | ConvertFrom-Json` 로 읽고 `$j.Features` 처럼 들어가 보세요. 값 바꾸기는 그냥 대입: `$j.Logging.LogLevel.Default = 'Warning'`, `$j.Features.NewCheckout = $true`
---
`$j.ConnectionStrings.Redis = '...'` 는 에러가 나요. 없는 속성에는 대입할 수 없거든요. `$j.ConnectionStrings | Add-Member -NotePropertyName Redis -NotePropertyValue '값'`
---
저장 전에 `$j | ConvertTo-Json` 을 화면에 찍어 보세요. 노란 **WARNING** 이 뜨고 `Provider` 가 `"@{Name=...}"` 같은 이상한 문자열로 바뀌죠? `ConvertTo-Json` 은 기본으로 **2단계 깊이까지만** 변환해요.
---
`$j | ConvertTo-Json -Depth 10 | Set-Content ~/app/appsettings.json`. 저장 후 `Get-Content ~/app/appsettings.json` 으로 `Provider` 와 `Retry` 가 제대로 남았는지 확인!
