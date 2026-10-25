먼저 `Import-Csv ~/sales.csv | Select-Object -First 5` 로 객체가 어떻게 생겼는지 보세요. `| Format-Table` 을 붙이면 표로 보여요.
---
지역별로 묶기: `Import-Csv ~/sales.csv | Group-Object region`. 각 그룹의 `.Group` 안에 그 지역 주문들이 들어 있어요.
---
그룹마다 합계: `... | Group-Object region | ForEach-Object { [pscustomobject]@{ Region = $_.Name; Total = ($_.Group | Measure-Object amount -Sum).Sum } } | Sort-Object Total -Descending`
---
⚠️ 함정: CSV 에서 읽은 값은 **문자열**이에요. `$_.amount -ge 500` 은 글자 순서로 비교해서 `"1200" -ge 500` 이 거짓이 됩니다! `[int]$_.amount -ge 500` 처럼 숫자로 바꿔서 비교하세요. 저장은 `| Export-Csv ~/big-orders.csv`
