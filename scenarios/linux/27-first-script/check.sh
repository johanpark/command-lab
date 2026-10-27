#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S="$H/bin/backup.sh"
expect "~/bin/backup.sh 가 있고 실행 권한이 있다" test -x "$S"
run() { as_learner bash -c "cd ~ && $1" 2>&1; }
out=$(run "'$S'"); rc=$?
[ $rc -eq 1 ] && grep -q '사용법' <<< "$out" && pass "인자 없이 실행하면 사용법을 보여주고 종료 코드 1" || fail "인자 없이 실행하면 사용법을 보여주고 종료 코드 1 (지금: 코드 $rc)"
out=$(run "'$S' ~/no-such-dir"); rc=$?
[ $rc -eq 2 ] && grep -q '폴더 없음' <<< "$out" && pass "없는 폴더면 '폴더 없음' 과 종료 코드 2" || fail "없는 폴더면 '폴더 없음' 과 종료 코드 2 (지금: 코드 $rc)"
rm -rf "$H/backups"
today=$(TZ=Asia/Seoul date +%Y%m%d)
for d in site blog; do
  out=$(run "'$S' ~/projects/$d"); rc=$?
  f="$H/backups/$d-$today.tar.gz"
  if [ $rc -eq 0 ] && [ -f "$f" ] && tar -tzf "$f" 2>/dev/null | grep -q "$( [ $d = site ] && echo index.html || echo README.md)" && grep -qF "$d-$today.tar.gz" <<< "$out"; then
    pass "backup.sh ~/projects/$d → ~/backups/$d-$today.tar.gz 를 만들고 경로를 출력"
  else
    fail "backup.sh ~/projects/$d → ~/backups/$d-$today.tar.gz 를 만들고 경로를 출력 (코드 $rc, 파일 $( [ -f "$f" ] && echo 있음 || echo 없음))"
  fi
done
finish
