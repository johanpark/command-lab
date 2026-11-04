# 설명: BOM 없이 UTF-8 로 저장하면 엑셀이 한글을 CP949 로 읽어 깨진다
# 실패해야: BOM 이 붙은 UTF-8
python3 - <<'PY'
import csv, os
src = "/home/learner/exports"
encodings = {"서울지점.csv": "cp949", "부산지점.csv": "utf-8-sig", "온라인몰.csv": "utf-8-sig"}
header, rows = None, []
for name, enc in encodings.items():
    with open(os.path.join(src, name), encoding=enc, newline="") as f:
        r = csv.reader(f)
        header = next(r)
        rows += [row for row in r if row]
os.makedirs("/home/learner/report", exist_ok=True)
with open("/home/learner/report/merged.csv", "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(header)
    w.writerows(rows)
open("/home/learner/answer.txt", "w").write(f"{sum(int(r[3]) for r in rows)}\n")
PY
