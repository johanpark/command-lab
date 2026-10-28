# 해설

```python
#!/usr/bin/env python3
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
with open("/home/learner/report/merged.csv", "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(header)
    w.writerows(rows)
open("/home/learner/answer.txt", "w").write(f"{sum(int(r[3]) for r in rows)}\n")
```

셸로만 한다면:
```bash
{ printf '\xef\xbb\xbf'
  iconv -f CP949 -t UTF-8 서울지점.csv | tr -d '\r'
  sed '1d; s/\r$//' 부산지점.csv
  sed '1d' 온라인몰.csv; } > merged.csv
```

## 인코딩 한눈에
| 인코딩 | 어디서 | 특징 |
|---|---|---|
| **UTF-8** | 리눅스, 맥, 웹, 대부분의 프로그램 | 전 세계 문자. 요즘 표준 |
| **UTF-8 + BOM** | 엑셀 "CSV UTF-8" 저장, 메모장 | 맨 앞 `EF BB BF` 3바이트. 엑셀이 UTF-8 로 알아보는 표시 |
| **CP949 / EUC-KR** | 윈도우 한국어 엑셀의 그냥 "CSV" 저장 | 한글 2바이트. 다른 프로그램에서 깨져 보임 |

## 엑셀과 BOM
엑셀은 BOM 이 **없는** UTF-8 CSV 를 열면 CP949 로 착각해서 한글을 깨뜨려요. 그래서 엑셀로 열 사람에게 줄 CSV 는 `utf-8-sig` 로, 프로그램이 읽을 CSV 는 BOM 없는 `utf-8` 로 저장하는 게 보통이에요. pandas 라면 `df.to_csv(..., encoding="utf-8-sig")`.

## 깨진 글자 진단 팁
- `ì•ˆë…•` 처럼 보이면: UTF-8 을 다른 인코딩으로 읽은 것
- `�` 가 잔뜩이면: CP949 를 UTF-8 로 읽은 것
- 맨 앞에 `ï»¿` 나 이상한 공백: BOM 을 그대로 읽은 것 (`utf-8-sig` 로 읽기)
