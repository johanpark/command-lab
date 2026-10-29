#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
W=/srv/www
want() { # 경로 → 기대 권한
  case "$1" in
    "$W/config/secret.php") echo 640 ;;
    "$W/bin/"*.sh) echo 755 ;;
    *) [ -d "$1" ] && echo 755 || echo 644 ;;
  esac
}
bad_d=""; bad_f=""; bad_x=""
while IFS= read -r p; do
  [ -e "$p" ] || continue
  m=$(stat -c %a "$p"); w=$(want "$p")
  [ "$m" = "$w" ] && continue
  case "$p" in
    "$W/config/secret.php"|"$W/bin/"*.sh) bad_x+="${p#$W/}($m) " ;;
    *) if [ -d "$p" ]; then bad_d+="${p#$W/}($m) "; else bad_f+="${p#$W/}($m) "; fi ;;
  esac
done < /opt/cmdlab/secret/all
[ -z "$bad_d" ] && pass "모든 폴더가 755 다" || fail "모든 폴더가 755 다 (예: $(cut -d' ' -f1-3 <<< "$bad_d"))"
[ -z "$bad_f" ] && pass "일반 파일이 모두 644 다 (실행 권한 없음)" || fail "일반 파일이 모두 644 다 (예: $(cut -d' ' -f1-3 <<< "$bad_f"))"
[ -z "$bad_x" ] && pass "bin/*.sh 는 755, config/secret.php 는 640 이다" || fail "bin/*.sh 는 755, config/secret.php 는 640 이다 (지금: $bad_x)"
expect "웹 서버(www-data)가 페이지와 비밀 설정을 읽을 수 있다" runuser -u www-data -- sh -c "cat $W/public/index.html $W/config/secret.php" 
expect "다른 사용자(nobody)는 비밀 설정을 못 읽는다" bash -c "! runuser -u nobody -- cat $W/config/secret.php"
expect "파일 내용·목록과 소유자는 그대로다" bash -c "[ \"\$(find $W -type f -exec md5sum {} + | sort -k2)\" = \"\$(cat /opt/cmdlab/secret/md5)\" ] && [ -z \"\$(find $W ! -user $LEARNER)\" ]"
finish
