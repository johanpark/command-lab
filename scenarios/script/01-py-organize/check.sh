#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
I="$H/inbox"; S="$H/sorted"
left=$(find "$I" -type f 2>/dev/null | wc -l)
[ "$left" -eq 0 ] && pass "~/inbox 에 남은 파일이 없다" || fail "~/inbox 에 남은 파일이 없다 (${left}개 남음 — 하위 폴더?)"
total=$(wc -l < /opt/cmdlab/secret/files)
lost=0; wrong=0
while IFS=$'\t' read -r sum cat; do
  where=$(find "$S" -type f -exec md5sum {} + 2>/dev/null | awk -v s="$sum" '$1 == s { print $2; exit }')
  if [ -z "$where" ]; then lost=$((lost + 1))
  else [[ "$where" == "$S/$cat/"* ]] || wrong=$((wrong + 1)); fi
done < /opt/cmdlab/secret/files
[ "$lost" -eq 0 ] && pass "사라진 파일이 없다 (${total}개 모두 ~/sorted 에 있음)" || fail "사라진 파일이 없다 (${lost}개 사라짐 — 같은 이름 덮어쓰기?)"
[ "$wrong" -eq 0 ] && pass "모든 파일이 맞는 종류 폴더에 있다" || fail "모든 파일이 맞는 종류 폴더에 있다 (${wrong}개가 엉뚱한 폴더 — 대문자 확장자?)"
# 고친 스크립트를 새 폴더에서 다시 시험
T=$(mktemp -d); chmod 755 "$T"; mkdir -p "$T/in/a/b" "$T/in/c"
echo 1 > "$T/in/a/b/X.PNG"; echo 2 > "$T/in/c/X.PNG"; echo 3 > "$T/in/X.png"; echo 4 > "$T/in/doc.TXT"
chown -R "$LEARNER" "$T"
out=$(as_learner timeout 20 python3 "$H/tools/organize.py" "$T/in" "$T/out" 2>&1)
n_img=$(find "$T/out/images" -type f 2>/dev/null | wc -l)
if [ "$n_img" -eq 3 ] && [ -f "$T/out/documents/doc.TXT" ] && [ -z "$(find "$T/in" -type f)" ]; then
  pass "고친 organize.py 가 새 폴더에서도 하위 폴더·대문자·같은 이름을 제대로 처리한다"
else
  fail "고친 organize.py 가 새 폴더에서도 하위 폴더·대문자·같은 이름을 제대로 처리한다 (images ${n_img}/3개$(grep -m1 -E 'Error|error' <<< "$out" | sed 's/^/ — /'))"
fi
rm -rf "$T"
finish
