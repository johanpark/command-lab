# 해설

```powershell
$j = Get-Content ~/app/appsettings.json -Raw | ConvertFrom-Json
$j.Logging.LogLevel.Default = 'Warning'
$j.Features.NewCheckout = $true
$j.ConnectionStrings | Add-Member -NotePropertyName Redis -NotePropertyValue 'cache-03.internal:6379'
$j | ConvertTo-Json -Depth 10 | Set-Content ~/app/appsettings.json
```

## -Depth 함정
`ConvertTo-Json` 의 기본 깊이는 **2** 예요. 그보다 깊은 객체는 경고 한 줄과 함께 **문자열로 뭉개져요.**
```json
"Provider": "@{Name=simple; TimeoutMs=300; Retry=}"
```
JSON 문법은 멀쩡해서 저장은 되는데, 서비스를 띄우면 설정을 못 읽어요. 그래서 **항상 `-Depth` 를 넉넉히** (예: 10, 최대 100) 주는 습관을 들이세요.

## 왜 텍스트 치환보다 나을까?
`-replace '"Default": "Debug"', '"Default": "Warning"'` 도 되긴 하지만 공백·순서가 조금만 달라도 실패하고, 같은 키가 여러 곳에 있으면 엉뚱한 곳이 바뀌어요. 객체로 다루면 **경로**(`Logging.LogLevel.Default`)로 정확히 고칠 수 있어요.

## 다른 도구에서는
| 도구 | 같은 작업 |
|---|---|
| `jq` (리눅스) | `jq '.Logging.LogLevel.Default = "Warning"' a.json > tmp && mv tmp a.json` |
| Python | `json.load` → 수정 → `json.dump(obj, f, indent=2, ensure_ascii=False)` |
| Node.js | `JSON.parse` → 수정 → `JSON.stringify(obj, null, 2)` |

PowerShell 7 이라면 `ConvertFrom-Json -AsHashtable` 로 해시테이블로 읽어서 `$j.ConnectionStrings['Redis'] = '...'` 처럼 Add-Member 없이 추가할 수도 있어요.
