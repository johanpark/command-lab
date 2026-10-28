#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/out/summary.xlsx"
top=$(head -n 1 /opt/cmdlab/secret/expected | cut -f1)
expect_answer "answer.txt 에 1등 지점을 적었다" "$top"
if [ ! -f "$F" ]; then fail "~/out/summary.xlsx 가 있다"; finish; fi
pass "~/out/summary.xlsx 가 있다"
out=$(python3 - "$F" <<'PY' 2>&1
import sys
from openpyxl import load_workbook
try:
    wb = load_workbook(sys.argv[1])
except Exception as e:
    print("ERR\t엑셀 파일을 열 수 없어요:", e); sys.exit()
if "지점별" not in wb.sheetnames:
    print("ERR\t'지점별' 시트가 없어요 (지금:", ", ".join(wb.sheetnames) + ")"); sys.exit()
for row in wb["지점별"].iter_rows(values_only=True):
    if all(v is None for v in row):
        continue
    vals = list(row[:2]) + [None] * (2 - len(row[:2]))
    kind = "num" if isinstance(vals[1], (int, float)) and not isinstance(vals[1], bool) else "text"
    v = int(vals[1]) if kind == "num" and float(vals[1]).is_integer() else vals[1]
    print(f"{vals[0]}\t{v}\t{kind}")
PY
)
if grep -q '^ERR' <<< "$out"; then fail "$(grep -m1 '^ERR' <<< "$out" | cut -f2-)"; finish; fi
expect "1행 머리글이 '지점', '매출합계' 다" test "$(head -n 1 <<< "$out" | cut -f1,2)" = "$(printf '지점\t매출합계')"
body=$(tail -n +2 <<< "$out")
expect "매출합계가 숫자로 저장됐다" bash -c '! grep -qv "	num$" <<< "$1"' _ "$body"
want=$(cat /opt/cmdlab/secret/expected)
got=$(cut -f1,2 <<< "$body")
if [ "$got" = "$want" ]; then pass "지점별 분기 합계가 맞고, 큰 순서로 정렬됐다"
elif [ "$(sort <<< "$got")" = "$(sort <<< "$want")" ]; then fail "지점별 분기 합계가 맞고, 큰 순서로 정렬됐다 (합계는 맞는데 순서가 달라요)"
else fail "지점별 분기 합계가 맞고, 큰 순서로 정렬됐다 (합계가 달라요 — 7·8·9월 시트를 모두 더했나요?)"; fi
finish
