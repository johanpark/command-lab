#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/reports"
total=$(rand_int 30000 99000)
secret_set total "$total"
for y in 2025 2026; do
  for q in Q1 Q2 Q3 Q4; do
    [ "$y" = 2026 ] && [ "$q" = Q4 ] && continue
    mkdir -p "$R/$y/$q"
    t=$(rand_int 20000 99000)
    [ "$y" = 2026 ] && [ "$q" = Q3 ] && t=$total
    printf '%s년 %s 매출 요약\n총매출: %s\n담당: 회계팀\n' "$y" "$q" "$t" > "$R/$y/$q/summary.txt"
    echo "date,amount" > "$R/$y/$q/detail.csv"
  done
done
echo "분기별 폴더 안에 summary.txt 가 있어요." > "$R/README.txt"
give "$R"
