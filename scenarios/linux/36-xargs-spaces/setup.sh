#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/reports"
rm -rf "$R"; mkdir -p "$R/2026/09" "$R/2026/10" "$R/team a" "$R/team b/old stuff" "$R/misc"
: > /opt/cmdlab/secret/csv
mk() { # 경로
  local f="$R/$1" n
  n=$(rand_int 5 40)
  { echo "date,item,qty,amount"; for i in $(seq 1 "$n"); do echo "2026-10-$(printf %02d $(rand_int 1 28)),item$(rand_int 1 99),$(rand_int 1 9),$(rand_int 1000 90000)"; done; } > "$f"
  printf '%s\t%s\n' "$f" "$(md5sum < "$f" | cut -d' ' -f1)" >> /opt/cmdlab/secret/csv
}
mk "2026/09/sales.csv"; mk "2026/09/returns.csv"; mk "2026/10/sales.csv"
mk "team a/weekly report.csv"; mk "team a/monthly report (final).csv"
mk "team b/q3 summary.csv"; mk "team b/old stuff/2025 backup.csv"
mk "misc/inventory.csv"
for i in $(seq 1 $(rand_int 1 3)); do mk "misc/export $i.csv"; done
# CSV 가 아닌 파일 (건드리면 안 됨)
echo "회의 메모" > "$R/team a/notes.txt"
echo "date,item" > "$R/misc/template.csv.bak"
echo "README" > "$R/README.md"
find "$R" -type f ! -name '*.csv' -exec md5sum {} + > /opt/cmdlab/secret/others
total=0; while IFS=$'\t' read -r f _; do total=$((total + $(wc -l < "$f"))); done < /opt/cmdlab/secret/csv
secret_set total "$total"
give "$R"
