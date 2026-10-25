# 객체 파이프라인으로 매출 분석

`~/sales.csv` 에 주문 기록이 있습니다.

```
id,date,region,product,amount
1001,2026-10-01,서울,키보드,320
```

PowerShell 파이프라인에는 텍스트가 아니라 **객체**가 흐릅니다. `Import-Csv` 를 쓰면 각 줄이 `id`, `region`, `amount` 속성을 가진 객체가 돼요.

## 목표
1. **지역(region)별 매출 합계**를 구해서, 합계가 가장 큰 지역 이름을 `~/answer.txt` 에 저장하세요.
2. **금액(amount)이 500 이상**인 주문만 골라서 `~/big-orders.csv` 로 저장하세요. (`Export-Csv` 사용, 열은 원본과 같게)

## 써볼 명령어
| cmdlet | 하는 일 |
|---|---|
| `Import-Csv 파일` | CSV → 객체 |
| `Where-Object { $_.amount -gt 10 }` | 조건에 맞는 객체만 (`$_` 는 지금 객체) |
| `Group-Object region` | 속성 값으로 묶기 |
| `Measure-Object amount -Sum` | 합계/평균/개수 |
| `Sort-Object 속성 -Descending` | 정렬 |
| `Export-Csv 파일` | 객체 → CSV |
