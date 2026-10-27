#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
if [ ! -f "$H/report.txt" ]; then
  fail "~/report.txt 에 카테고리별 매출이 큰 순서로 있다 (파일이 없어요)"
else
  got=$(tr -d '\r' < "$H/report.txt" | tr ',\t' '  ' | tr -s ' ' | sed -e 's/^ //' -e 's/ $//' -e '/^$/d')
  if [ "$got" = "$(cat /opt/cmdlab/secret/report)" ]; then
    pass "~/report.txt 에 카테고리별 매출이 큰 순서로 있다"
  elif grep -q 'category' <<< "$got"; then
    fail "~/report.txt 에 카테고리별 매출이 큰 순서로 있다 (머리글 줄 'category' 가 섞여 있어요 → NR > 1)"
  else
    fail "~/report.txt 에 카테고리별 매출이 큰 순서로 있다 (값이나 순서가 달라요. sort -k2 -nr 로 정렬했나요?)"
  fi
fi
top=$(head -n 1 /opt/cmdlab/secret/qty | cut -d' ' -f1)
got=$(answer)
if awk -v t="$top" -v g="$got" '$1 == t && $2 == g { ok = 1 } END { exit !ok }' /opt/cmdlab/secret/qty; then
  pass "answer.txt 에 판매 수량 1위 상품을 적었다"
else
  fail "answer.txt 에 판매 수량 1위 상품을 적었다 (지금 적힌 값: '$got')"
fi
finish
