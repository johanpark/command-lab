# 설명: 합계를 '1,234' 같은 글자로 저장하면 엑셀에서 숫자 계산이 안 된다
# 실패해야: 매출합계가 숫자로
mkdir -p ~/out
cat > ~/tools/report.py <<'PY'
#!/usr/bin/env python3
from collections import defaultdict
from pathlib import Path
from openpyxl import Workbook, load_workbook

home = Path.home()
wb = load_workbook(home / "data/sales_2026Q3.xlsx", data_only=True)
totals = defaultdict(int)
for name in wb.sheetnames:
    if not name.endswith("월"):
        continue
    for row in wb[name].iter_rows(min_row=2, values_only=True):
        branch, amount = row[1], row[4]
        if branch is None:
            continue
        if isinstance(amount, str):
            amount = int(amount.replace(",", ""))
        totals[branch] += amount

ranked = sorted(totals.items(), key=lambda x: x[1], reverse=True)
out = Workbook()
ws = out.active
ws.title = "지점별"
ws.append(["지점", "매출합계"])
for branch, total in ranked:
    ws.append([branch, f"{total:,}"])
out.save(home / "out/summary.xlsx")
(home / "answer.txt").write_text(ranked[0][0] + "\n")
PY
python3 ~/tools/report.py
