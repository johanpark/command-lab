#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
cpu=$(secret_get cpu); mem=$(secret_get mem)
# top 은 화면이 좁으면 긴 이름을 'search-+' 처럼 잘라서 보여주므로 그것도 인정한다
name_ok() { local got; got=$(answer "$1") || return 1; [ "$got" = "$2" ] || { [[ $got == *+ ]] && [[ $2 == "${got%+}"* ]]; }; }
for pair in "cpu.txt:$cpu:CPU 를 튀게 하는" "mem.txt:$mem:메모리를 가장 많이 쓰는"; do
  IFS=: read -r f want what <<< "$pair"
  if name_ok "$H/$f" "$want"; then pass "$f 에 $what 프로세스 이름을 적었다"
  elif [ -f "$H/$f" ]; then fail "$f 에 $what 프로세스 이름을 적었다 (지금 적힌 값: '$(answer "$H/$f")')"
  else fail "$f 에 $what 프로세스 이름을 적었다 (파일이 없어요)"; fi
done
R="$H/top-report.txt"
if [ -f "$R" ] && grep -q 'load average' "$R" && grep -qE '^ *PID +USER' "$R" && [ "$(wc -l < "$R")" -ge 8 ]; then
  pass "top-report.txt 에 top 화면(요약 + 프로세스 목록)이 저장됐다"
else
  fail "top-report.txt 에 top 화면(요약 + 프로세스 목록)이 저장됐다 (top -b -n 1 > ~/top-report.txt)"
fi
alive=0; for p in "$cpu" "$mem" web-server queue-worker; do pgrep -x "$p" >/dev/null && alive=$((alive + 1)); done
[ "$alive" -eq 4 ] && pass "아무 프로세스도 종료하지 않았다" || fail "아무 프로세스도 종료하지 않았다 (관찰만 하라고 했어요! 웹에서는 '↺ 처음부터', 터미널에서는 lab reset 으로 다시 시작)"
finish
