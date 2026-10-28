#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/report/summary.json"
cmp_json() { # 파일 → 항목별 비교 결과 (ok/값)
  node -e '
    const fs = require("fs");
    const want = JSON.parse(fs.readFileSync("/opt/cmdlab/secret/expected.json", "utf8"));
    let got;
    try { got = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); } catch (e) { console.log("parse\t" + e.message.split("\n")[0]); process.exit(); }
    for (const k of ["paidOrders", "revenue", "broken"]) {
      const g = JSON.stringify(got[k]), w = JSON.stringify(want[k]);
      console.log(k + "\t" + (g === w ? "ok" : (g ?? "없음")));
    }' "$1"
}
[ -f "$R" ] && pass "~/report/summary.json 이 있다" || fail "~/report/summary.json 이 있다"
# 스크립트를 다시 돌려서 같은 결과가 나오는지
mv -f "$R" "$R.bak" 2>/dev/null
out=$(as_learner timeout 20 node "$H/tools/summary.js" 2>&1); rc=$?
if [ $rc -eq 0 ] && [ -f "$R" ]; then pass "summary.js 가 깨진 파일이 있어도 멈추지 않고 끝까지 실행된다"
else fail "summary.js 가 깨진 파일이 있어도 멈추지 않고 끝까지 실행된다 ($(grep -m1 -E 'Error' <<< "$out" || echo "종료 코드 $rc"))"; fi
if [ -f "$R" ]; then
  res=$(cmp_json "$R")
  if grep -q '^parse' <<< "$res"; then fail "summary.json 이 올바른 JSON 이다 ($(cut -f2 <<< "$res"))"
  else
    r() { grep "^$1	" <<< "$res" | cut -f2; }
    [ "$(r paidOrders)" = ok ] && pass "paidOrders: paid 주문 수가 맞다" || fail "paidOrders: paid 주문 수가 맞다 (지금: $(r paidOrders) — refunded/cancelled 를 뺐나요?)"
    [ "$(r revenue)" = ok ] && pass "revenue: paid 주문 매출 합계가 맞다" || fail "revenue: paid 주문 매출 합계가 맞다 (지금: $(r revenue))"
    [ "$(r broken)" = ok ] && pass "broken: 깨진 파일 이름이 정렬돼 있다" || fail "broken: 깨진 파일 이름이 정렬돼 있다 (지금: $(r broken))"
  fi
fi
rm -f "$R.bak"
finish
