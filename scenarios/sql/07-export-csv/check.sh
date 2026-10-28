#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/report.csv"; E=/opt/cmdlab/secret/expected.csv
[ -f "$F" ] || { fail "~/report.csv 가 있다"; finish; }
pass "~/report.csv 가 있다"
got=$(sed -e 's/\r$//' -e '1s/^\xef\xbb\xbf//' "$F" | sed '/^[[:space:]]*$/d')
if grep -q '[│┌─]' <<< "$got"; then fail "CSV 형식이다 (표 테두리 ┌─┐ 가 들어 있어요 — sqlite3 가 -box 별칭이에요)"
else pass "CSV 형식이다"; fi
h=$(head -n 1 <<< "$got" | tr -d '"')
[ "$h" = "월,주문수,매출" ] && pass "머리글이 '월,주문수,매출' 이다" || fail "머리글이 '월,주문수,매출' 이다 (지금: '$h')"
body=$(tail -n +2 <<< "$got" | tr -d '"'); want=$(tail -n +2 "$E")
if [ "$body" = "$want" ]; then pass "월별 주문수·매출이 맞고 월 순서로 정렬됐다 (paid 만)"
elif [ "$(sort <<< "$body")" = "$(sort <<< "$want")" ]; then fail "월별 주문수·매출이 맞고 월 순서로 정렬됐다 (값은 맞는데 순서가 달라요)"
elif [ "$(cut -d, -f1 <<< "$body")" = "$(cut -d, -f1 <<< "$want")" ]; then fail "월별 주문수·매출이 맞고 월 순서로 정렬됐다 (숫자가 달라요 — cancelled, refunded 를 뺐나요?)"
else fail "월별 주문수·매출이 맞고 월 순서로 정렬됐다 (지금 $(wc -l <<< "$body")줄, 기대 $(wc -l <<< "$want")줄)"; fi
finish
