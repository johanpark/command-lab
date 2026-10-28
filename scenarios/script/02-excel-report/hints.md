대화형 파이썬으로 엑셀을 들여다보세요:
```python
from openpyxl import load_workbook
wb = load_workbook("/home/learner/data/sales_2026Q3.xlsx")
wb.sheetnames
for row in wb["9월"].iter_rows(min_row=2, max_row=6, values_only=True): print(row)
```
9월 시트의 금액은 `'1,250,000'` 같은 **텍스트**예요. 쉼표가 들어간 숫자 문자열이죠.
---
report.py 는 `wb.active` 하나만 읽어요. 월 시트 전부를 돌아야 해요:
```python
for name in ["7월", "8월", "9월"]:      # 또는 if name.endswith("월")
    for row in wb[name].iter_rows(min_row=2, values_only=True):
```
---
금액을 숫자로: 텍스트면 쉼표를 지우고 `int()`:
```python
amount = row[4]
if isinstance(amount, str):
    amount = int(amount.replace(",", ""))
```
시트 끝에 **빈 줄**도 있어요. `if row[1] is None: continue` 로 건너뛰세요.
---
정렬과 저장:
```python
from openpyxl import Workbook
out = Workbook(); ws = out.active; ws.title = "지점별"
ws.append(["지점", "매출합계"])
for branch, total in sorted(totals.items(), key=lambda x: x[1], reverse=True):
    ws.append([branch, total])
out.save("/home/learner/out/summary.xlsx")
```
`~/out` 폴더가 없으면 `mkdir -p ~/out` 먼저!
