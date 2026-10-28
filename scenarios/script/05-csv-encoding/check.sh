#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/report/merged.csv"
expect_answer "answer.txt 에 세 지점 금액 합계를 적었다" "$(cat /opt/cmdlab/secret/total)"
[ -f "$F" ] || { fail "~/report/merged.csv 가 있다"; finish; }
pass "~/report/merged.csv 가 있다"
res=$(python3 - "$F" <<'PY'

import sys
data = open(sys.argv[1], "rb").read()
def res(ok, msg): print(("ok" if ok else "no") + "\t" + msg)
res(data.startswith(b"\xef\xbb\xbf"), "BOM 이 붙은 UTF-8 이다 (엑셀에서 한글이 안 깨짐)" + ("" if data.startswith(b"\xef\xbb\xbf") else f" (맨 앞: {data[:3].hex(' ')})"))
try:
    text = data.decode("utf-8-sig")
except UnicodeDecodeError as e:
    res(False, f"파일 전체가 올바른 UTF-8 이다 ({e.start}번째 바이트에서 깨짐 — CP949 그대로 섞였나요?)"); sys.exit()
res(True, "파일 전체가 올바른 UTF-8 이다")
lines = [l.rstrip("\r") for l in text.split("\n") if l.strip()]
headers = sum(1 for l in lines if l.lstrip("﻿").startswith("날짜,"))
res(lines and lines[0] == "날짜,지점,상품,금액" and headers == 1, f"머리글이 맨 위에 한 번만 있다 (지금 {headers}번)")
res("﻿" not in "\n".join(lines), "중간에 BOM(\\ufeff) 이 끼어 있지 않다")
want = sorted(open("/opt/cmdlab/secret/rows", encoding="utf-8").read().strip().split("\n"))
got = sorted(l.lstrip("﻿") for l in lines[1:] if not l.lstrip("﻿").startswith("날짜,"))
res(got == want, f"세 지점 거래가 빠짐없이 그대로 들어 있다 (지금 {len(got)}줄, 기대 {len(want)}줄)")
PY
)
while IFS=$'\t' read -r st msg; do [ "$st" = ok ] && pass "$msg" || fail "$msg"; done <<< "$res"
finish
