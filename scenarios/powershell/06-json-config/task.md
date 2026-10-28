# JSON 설정 파일 고치기

서비스 설정 `~/app/appsettings.json` 을 운영 배포 전에 고쳐야 해요. 요청 내용은 `~/request.txt` 에 있어요. JSON 을 손으로 고치다 쉼표 하나 빠뜨리면 서비스가 안 뜨니까, **PowerShell 객체로 읽어서** 고쳐 보세요.

## 목표
`~/app/appsettings.json` 에서
1. `Logging.LogLevel.Default` 를 **`Warning`** 으로
2. `Features.NewCheckout` 을 **`true`** (문자열 말고 진짜 true)로
3. `ConnectionStrings` 에 **`Redis`** 항목을 새로 추가 (값은 `~/request.txt` 에 있어요)
4. 나머지 설정은 **하나도 바뀌거나 깨지면 안 돼요.** 저장한 파일은 올바른 JSON 이어야 해요.

## 써볼 cmdlet
| cmdlet | 하는 일 |
|---|---|
| `Get-Content 파일 -Raw \| ConvertFrom-Json` | JSON 을 객체로 |
| `$j.Logging.LogLevel` | 점(.)으로 안쪽 값 보기 |
| `$j.Features.NewCheckout = $true` | 값 바꾸기 |
| `$obj \| Add-Member -NotePropertyName 이름 -NotePropertyValue 값` | **없던** 속성 추가 |
| `$j \| ConvertTo-Json -Depth 숫자` | 객체를 JSON 으로 (깊이 지정) |
| `Set-Content 파일` | 파일에 저장 |
