#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
A="$H/app-config"
# changed.txt 의 경로를 app-config 기준 상대 경로로 맞춘다 (절대/~/./ 모두 허용)
norm() {
  tr -d '\r' < "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d' \
    -e "s#^$H/#~/#" -e 's#^~/app-config/##' -e 's#^app-config/##' -e 's#^\./##' | sort -u
}
if [ ! -f "$H/changed.txt" ]; then
  fail "~/changed.txt 에 최근 1일 이내 수정된 .conf 목록이 있다 (파일이 없어요)"
else
  got=$(norm "$H/changed.txt"); want=$(sort /opt/cmdlab/secret/changed)
  if [ "$got" = "$want" ]; then pass "~/changed.txt 에 최근 1일 이내 수정된 .conf 목록이 있다 ($(echo "$want" | wc -l)개)"
  else fail "~/changed.txt 에 최근 1일 이내 수정된 .conf 목록이 있다 (기대 $(echo "$want" | wc -l)개, 지금 $(echo "$got" | sed '/^$/d' | wc -l)개 — .conf 만, 1일 이내만 맞나요?)"; fi
fi
empty=$(find "$A" -type f -empty | wc -l)
[ "$empty" -eq 0 ] && pass "빈 파일을 모두 지웠다" || fail "빈 파일을 모두 지웠다 (${empty}개 남음)"
lost=0
while IFS= read -r f; do [ -e "$f" ] || lost=$((lost + 1)); done < /opt/cmdlab/secret/nonempty
[ "$lost" -eq 0 ] && pass "내용이 있는 파일은 그대로 있다" || fail "내용이 있는 파일은 그대로 있다 (${lost}개 사라짐!)"
expect "폴더는 지우지 않았다 (빈 폴더 empty-dir 포함)" test -d "$A/empty-dir"
finish
