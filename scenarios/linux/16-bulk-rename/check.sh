#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
P="$H/photos"
miss=0
while IFS= read -r b; do [ -f "$P/2026-trip_$b.jpg" ] || miss=$((miss + 1)); done < /opt/cmdlab/secret/names
total=$(wc -l < /opt/cmdlab/secret/names)
[ "$miss" -eq 0 ] && pass "사진 ${total}개가 모두 '2026-trip_이름.jpg' 가 됐다" || fail "사진 ${total}개가 모두 '2026-trip_이름.jpg' 가 됐다 (${miss}개 아직 — 공백이 든 이름은 따옴표!)"
left=$(find "$P" -maxdepth 1 -name '*.JPG' | wc -l)
[ "$left" -eq 0 ] && pass ".JPG 파일이 남아 있지 않다" || fail ".JPG 파일이 남아 있지 않다 (${left}개 남음)"
extra=$(find "$P" -maxdepth 1 -type f ! -name '2026-trip_*.jpg' ! -name notes.txt | wc -l)
[ "$extra" -eq 0 ] && pass "이상한 이름의 파일이 생기지 않았다" || fail "이상한 이름의 파일이 생기지 않았다 (${extra}개: ls 로 확인해 보세요)"
expect "notes.txt 는 그대로다" test -f "$P/notes.txt"
finish
