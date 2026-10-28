#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/reports"
expect_answer "answer.txt 에 모든 .csv 의 줄 수 합계를 적었다" "$(secret_get total)"
left=$(find "$R" -name '*.csv' | wc -l)
[ "$left" -eq 0 ] && pass "압축되지 않은 .csv 가 남아 있지 않다" || fail "압축되지 않은 .csv 가 남아 있지 않다 (${left}개 남음 — 이름에 공백이 있는 파일?)"
bad=0
while IFS=$'\t' read -r f sum; do
  [ -f "$f.gz" ] && [ "$(zcat "$f.gz" 2>/dev/null | md5sum | cut -d' ' -f1)" = "$sum" ] || bad=$((bad + 1))
done < /opt/cmdlab/secret/csv
[ "$bad" -eq 0 ] && pass "모든 .csv 가 제자리에서 .csv.gz 로 압축됐다 (내용 그대로)" || fail "모든 .csv 가 제자리에서 .csv.gz 로 압축됐다 (${bad}개가 없거나 내용이 달라요)"
expect ".csv 가 아닌 파일은 그대로다" md5sum --quiet -c /opt/cmdlab/secret/others
finish
