#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
E="$H/exports"; rm -rf "$E" "$H/report"; mkdir -p "$E"
python3 - "$E" "$RANDOM" <<'PY'
import random, sys
out, seed = sys.argv[1], int(sys.argv[2])
rnd = random.Random(seed)
products = ["노트북 거치대", "무선 키보드", "한글 자판 스티커", "모니터 받침대", "USB 허브", "마우스 패드", "웹캠", "블루투스 스피커"]
spec = [("서울지점.csv", "서울", "cp949", "\r\n"), ("부산지점.csv", "부산", "utf-8-sig", "\r\n"), ("온라인몰.csv", "온라인", "utf-8", "\n")]
expected = []
for fname, branch, enc, nl in spec:
    lines = ["날짜,지점,상품,금액"]
    for _ in range(rnd.randint(12, 25)):
        row = [f"2026-10-{rnd.randint(1, 27):02d}", branch, rnd.choice(products), str(rnd.randint(5, 120) * 1000)]
        lines.append(",".join(row)); expected.append(",".join(row))
    with open(f"{out}/{fname}", "w", encoding=enc, newline="") as f:
        f.write(nl.join(lines) + nl)
with open("/opt/cmdlab/secret/rows", "w", encoding="utf-8") as f:
    f.write("\n".join(sorted(expected)) + "\n")
with open("/opt/cmdlab/secret/total", "w") as f:
    f.write(str(sum(int(r.split(",")[3]) for r in expected)))
PY
give "$E"
