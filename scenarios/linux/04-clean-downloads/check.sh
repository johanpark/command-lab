#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
D="$H/Downloads"
missing() { # 패턴에 맞는 원래 파일들이 dir 에 다 있는지
  local dir=$1; shift
  local miss=0 f
  while IFS= read -r f; do
    for p in "$@"; do
      # shellcheck disable=SC2053
      if [[ $f == $p ]] && [ ! -f "$dir/$f" ]; then miss=$((miss+1)); fi
    done
  done < /opt/cmdlab/secret/files.txt
  echo "$miss"
}
expect "images/ 와 docs/ 폴더가 있다" test -d "$D/images" -a -d "$D/docs"
m=$(missing "$D/images" '*.jpg' '*.JPG' '*.png')
[ "$m" -eq 0 ] && pass "사진(.jpg/.JPG/.png)이 모두 images/ 에 있다" || fail "사진(.jpg/.JPG/.png)이 모두 images/ 에 있다 (${m}개 빠짐)"
m=$(missing "$D/docs" '*.pdf')
[ "$m" -eq 0 ] && pass "문서(.pdf)가 모두 docs/ 에 있다" || fail "문서(.pdf)가 모두 docs/ 에 있다 (${m}개 빠짐)"
left=$(find "$D" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.pdf' \) | wc -l)
[ "$left" -eq 0 ] && pass "~/Downloads 에 사진/문서가 남아 있지 않다" || fail "~/Downloads 에 사진/문서가 남아 있지 않다 (${left}개 남음)"
tmp=$(find "$D" -name '*.tmp' | wc -l)
[ "$tmp" -eq 0 ] && pass ".tmp 파일이 모두 삭제됐다" || fail ".tmp 파일이 모두 삭제됐다 (${tmp}개 남음)"
m=$(missing "$D" '*.zip')
[ "$m" -eq 0 ] && pass ".zip 파일은 ~/Downloads 에 그대로 있다" || fail ".zip 파일은 ~/Downloads 에 그대로 있다 (${m}개 없음)"
finish
