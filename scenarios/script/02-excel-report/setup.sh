#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/data" "$H/tools"; rm -rf "$H/out"
python3 - "$H/data/sales_2026Q3.xlsx" "$RANDOM" <<'PY'
import random, sys
from collections import defaultdict
from openpyxl import Workbook
path, seed = sys.argv[1], int(sys.argv[2])
rnd = random.Random(seed)
branches = ["강남점", "판교점", "부산점", "대구점", "광주점", "홍대점"]
weights = [rnd.uniform(0.6, 1.6) for _ in branches]
products = [("노트북", 1250000), ("모니터", 329000), ("키보드", 89000), ("마우스", 39000), ("태블릿", 690000)]
wb = Workbook()
info = wb.active; info.title = "설명"
info.append(["2026년 3분기 매출"]); info.append(["월별 시트에 거래 1건이 한 줄씩 있습니다."]); info.append(["금액 = 단가 × 수량 (원)"])
totals = defaultdict(int)
for month in (7, 8, 9):
    ws = wb.create_sheet(f"{month}월")
    ws.append(["날짜", "지점", "상품", "수량", "금액"])
    for _ in range(rnd.randint(40, 60)):
        b = rnd.choices(branches, weights)[0]
        name, price = rnd.choice(products)
        qty = rnd.randint(1, 5)
        amount = price * qty
        totals[b] += amount
        # 9월은 다른 시스템에서 내려받아 금액이 '1,250,000' 같은 텍스트
        ws.append([f"2026-{month:02d}-{rnd.randint(1, 30):02d}", b, name, qty, f"{amount:,}" if month == 9 else amount])
    for _ in range(rnd.randint(2, 4)):
        ws.append([None, None, None, None, None])
wb.active = 3  # 마지막에 작업한 9월 시트가 열린 채로 저장됨
wb.save(path)
ranked = sorted(totals.items(), key=lambda x: x[1], reverse=True)
with open("/opt/cmdlab/secret/expected", "w") as f:
    for b, t in ranked:
        f.write(f"{b}\t{t}\n")
PY
cat > "$H/tools/report.py" <<'PY'
#!/usr/bin/env python3
"""분기 매출 엑셀에서 지점별 합계를 계산한다. (작성: 전 담당자)"""
from openpyxl import load_workbook

wb = load_workbook("/home/learner/data/sales_2026Q3.xlsx")
ws = wb.active

totals = {}
for row in ws.iter_rows(min_row=2, values_only=True):
    branch = row[1]
    amount = int(row[4])
    totals[branch] = totals.get(branch, 0) + amount

for branch, total in totals.items():
    print(branch, total)
# TODO: 엑셀로 저장하기
PY
give "$H/data" "$H/tools"
