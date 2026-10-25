#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 2026년 Q3 총매출을 적었다" "$(secret_get total)"
expect "~/archive 폴더가 있다" test -d "$H/archive"
expect "~/archive/summary.txt 가 Q3 요약과 같다" cmp -s "$H/archive/summary.txt" "$H/reports/2026/Q3/summary.txt"
expect "원본 요약 파일은 그대로 있다" test -f "$H/reports/2026/Q3/summary.txt"
finish
