`file ~/exports/*.csv` 를 쳐 보세요. `UTF-8 (with BOM)`, `UTF-8`, `ISO-8859`(정체를 모르는 8비트 = 대개 CP949) 처럼 달라요. 서울지점은 `iconv -f CP949 -t UTF-8 ~/exports/서울지점.csv | head` 로 보면 한글이 보여요.
---
`cat ~/exports/*.csv > merged.csv` 로 합치면 세 가지 문제가 생겨요. ① 인코딩이 섞여 깨지고 ② 머리글이 세 번 나오고 ③ 부산지점의 BOM(`﻿`)이 중간에 끼어요.
---
파이썬으로 파일마다 맞는 인코딩으로 읽으면 깔끔해요:
```python
import csv
files = {"서울지점.csv": "cp949", "부산지점.csv": "utf-8-sig", "온라인몰.csv": "utf-8-sig"}
rows = []
for name, enc in files.items():
    with open(f"/home/learner/exports/{name}", encoding=enc, newline="") as f:
        r = csv.reader(f)
        header = next(r)          # 머리글은 건너뛰고
        rows += list(r)
```
(`utf-8-sig` 는 BOM 이 없는 UTF-8 도 잘 읽어요)
---
저장과 합계:
```python
import os
os.makedirs("/home/learner/report", exist_ok=True)
with open("/home/learner/report/merged.csv", "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f); w.writerow(header); w.writerows(rows)
print(sum(int(r[3]) for r in rows))
```
