#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
L="$H/backup/backup.log"
# 스크립트를 실행 중인 bash 만 (인자 중 하나가 정확히 .../long-backup.sh). grep, 셸 명령줄 등은 제외
pids=$(pgrep -u "$LEARNER" -f 'long-backup\.sh' | while read -r p; do
  tr '\0' '\n' < "/proc/$p/cmdline" 2>/dev/null | tail -n +2 | grep -qxE '([^ ]*/)?long-backup\.sh' && echo "$p"
done)
if [ -z "$pids" ]; then
  fail "long-backup.sh 가 실행 중이다 (지금 안 돌고 있어요)"
  finish
fi
pass "long-backup.sh 가 실행 중이다"
ok=0; why=""
for p in $pids; do
  ign=$(awk '/^SigIgn:/ { print $2 }' "/proc/$p/status" 2>/dev/null)
  tty=$(ps -o tty= -p "$p" | tr -d ' ')
  # SIGHUP(1번) 을 무시하거나, 터미널과 분리돼 있으면 터미널이 닫혀도 산다
  if [ -n "$ign" ] && [ $(( 0x$ign & 1 )) -eq 1 ]; then ok=1
  elif [ "$tty" = "?" ]; then ok=1
  else why="SIGHUP 을 받으면 죽어요 — nohup 을 붙였나요?"; fi
done
[ "$ok" = 1 ] && pass "터미널이 닫혀도(SIGHUP) 계속 돈다" || fail "터미널이 닫혀도(SIGHUP) 계속 돈다 ($why)"
out=""
for p in $pids; do out=$(as_learner readlink "/proc/$p/fd/1" 2>/dev/null); [ -n "$out" ] && break; done
if [ "$out" = "$L" ]; then pass "출력이 ~/backup/backup.log 로 간다"
else fail "출력이 ~/backup/backup.log 로 간다 (지금: ${out/#$H/\~})"; fi
err=$(as_learner readlink "/proc/$(head -n 1 <<< "$pids")/fd/2" 2>/dev/null)
[ "$err" = "$L" ] && pass "에러도 같은 로그로 간다 (2>&1)" || fail "에러도 같은 로그로 간다 (2>&1) (지금: ${err/#$H/\~})"
expect "로그에 진행 상황이 쌓이고 있다" grep -q '백업 시작' "$L"
finish
