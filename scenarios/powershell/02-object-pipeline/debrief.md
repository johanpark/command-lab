# 해설

```powershell
$sales = Import-Csv ~/sales.csv

# 1. 지역별 합계
$sales | Group-Object region |
  ForEach-Object {
    [pscustomobject]@{ Region = $_.Name; Total = ($_.Group | Measure-Object amount -Sum).Sum }
  } |
  Sort-Object Total -Descending

# 2. 500 이상 주문 저장
$sales | Where-Object { [int]$_.amount -ge 500 } | Export-Csv ~/big-orders.csv
```

## 텍스트 파이프라인 vs 객체 파이프라인
bash 라면 `awk -F, '{ s[$3] += $5 } END { ... }'` 처럼 **몇 번째 칸인지** 세어야 하지만, PowerShell 은 `region`, `amount` 처럼 **이름으로** 다룹니다. 열 순서가 바뀌어도 스크립트가 깨지지 않아요.

## 꼭 기억할 함정
`Import-Csv` 의 값은 모두 **문자열**입니다.
```powershell
"1200" -ge 500        # False  (문자열 비교: "1" < "5")
[int]"1200" -ge 500   # True
500 -le "1200"        # True   (왼쪽이 숫자면 오른쪽을 숫자로 변환)
```
PowerShell 은 **왼쪽 값의 타입**을 기준으로 비교합니다. 숫자 비교가 이상하면 타입부터 의심하세요: `$x.GetType().Name`

## 유용한 조합
```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU
Get-ChildItem -Recurse -File | Sort-Object Length -Descending | Select-Object -First 5 FullName, Length
Get-ChildItem *.log | Measure-Object Length -Sum
```
