# 해설

```python
#!/usr/bin/env python3
from collections import defaultdict
from pathlib import Path
from openpyxl import Workbook, load_workbook

home = Path.home()
wb = load_workbook(home / "data/sales_2026Q3.xlsx", data_only=True)

totals = defaultdict(int)
for name in wb.sheetnames:
    if not name.endswith("월"):              # '설명' 시트 건너뛰기
        continue
    for row in wb[name].iter_rows(min_row=2, values_only=True):
        date, branch, product, qty, amount = row[:5]
        if branch is None:                    # 빈 줄
            continue
        if isinstance(amount, str):           # '1,250,000' → 1250000
            amount = int(amount.replace(",", ""))
        totals[branch] += amount

out = Workbook()
ws = out.active
ws.title = "지점별"
ws.append(["지점", "매출합계"])
for branch, total in sorted(totals.items(), key=lambda x: x[1], reverse=True):
    ws.append([branch, total])
(home / "out").mkdir(exist_ok=True)
out.save(home / "out/summary.xlsx")
(home / "answer.txt").write_text(next(iter(sorted(totals, key=totals.get, reverse=True))) + "\n")
```

## 실무 엑셀의 단골 함정
| 함정 | 증상 | 대처 |
|---|---|---|
| 숫자가 텍스트로 저장 | 엑셀에서 왼쪽 정렬, 초록 삼각형 | `str` 이면 `replace(",", "")` 후 `int` |
| 빈 줄·합계 줄 | `None`, "합계" 같은 값 | 건너뛰기 조건 |
| 시트가 여러 개 | `wb.active` 는 하나만 | `wb.sheetnames` 로 돌기 |
| 수식 셀 | 값 대신 `=SUM(...)` 문자열 | `load_workbook(..., data_only=True)` |
| 날짜 | `datetime` 객체로 읽힘 | `.strftime("%Y-%m")` |

## 반복되는 일이라면
매달 같은 보고서를 만든다면 스크립트를 **인자로 파일을 받게** 고치고(`sys.argv[1]`), 다음 시나리오처럼 **cron** 으로 자동 실행하면 손이 안 가요. 데이터가 크거나 피벗·그래프까지 필요하면 `pandas` (`pd.read_excel(..., sheet_name=None)` 이면 모든 시트를 한 번에) 가 편해요.
