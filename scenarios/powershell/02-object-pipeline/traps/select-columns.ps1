# 설명: Select-Object 로 열을 줄이면 원본과 열이 달라진다
# 실패해야: 열이 원본과 같다
$sales = Import-Csv ~/sales.csv
$top = $sales | Group-Object region |
  ForEach-Object { [pscustomobject]@{ Region = $_.Name; Total = ($_.Group | Measure-Object amount -Sum).Sum } } |
  Sort-Object Total -Descending | Select-Object -First 1
Set-Content ~/answer.txt $top.Region
$sales | Where-Object { [int]$_.amount -ge 500 } | Select-Object id, amount | Export-Csv ~/big-orders.csv
