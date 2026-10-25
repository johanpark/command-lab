$sales = Import-Csv ~/sales.csv
$top = $sales | Group-Object region |
  ForEach-Object { [pscustomobject]@{ Region = $_.Name; Total = ($_.Group | Measure-Object amount -Sum).Sum } } |
  Sort-Object Total -Descending | Select-Object -First 1
Set-Content ~/answer.txt $top.Region
$sales | Where-Object { [int]$_.amount -ge 500 } | Export-Csv ~/big-orders.csv
