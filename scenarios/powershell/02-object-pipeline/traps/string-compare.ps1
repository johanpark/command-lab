# 설명: CSV 값은 글자라서 [int] 없이 비교하면 '90' -ge 500 이 글자 비교가 된다
# 실패해야: 500 이상 주문만
$sales = Import-Csv ~/sales.csv
$top = $sales | Group-Object region |
  ForEach-Object { [pscustomobject]@{ Region = $_.Name; Total = ($_.Group | Measure-Object amount -Sum).Sum } } |
  Sort-Object Total -Descending | Select-Object -First 1
Set-Content ~/answer.txt $top.Region
$sales | Where-Object { $_.amount -ge '500' } | Export-Csv ~/big-orders.csv
