#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
P="$H/photos"; B=/mnt/backup/photos
expect "백업 안에 photos 폴더가 중첩되지 않았다 (끝 슬래시)" test ! -e "$B/photos"
expect "백업 내용이 원본과 똑같다 (추가·변경·삭제 반영)" diff -r "$P" "$B"
# 권한과 수정 시각(초 단위)
meta() { (cd "$1" && find . -type f -printf '%P %m %T@\n' | awk '{ split($3, t, "."); print $1, $2, t[1] }' | sort); }
[ "$(meta "$P")" = "$(meta "$B")" ] && pass "파일 권한과 수정 시각도 원본과 같다 (-a)" || fail "파일 권한과 수정 시각도 원본과 같다 (-a 옵션을 썼나요?)"
expect "원본 ~/photos 는 그대로다" test "$(find "$P" -type f | wc -l)" -eq 14
finish
