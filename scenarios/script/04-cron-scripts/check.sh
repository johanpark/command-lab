#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
J="$H/jobs"
tab=$(crontab -u "$LEARNER" -l 2>/dev/null)
# cron 처럼: 변수 줄은 그대로(치환 없이), 명령은 홈 폴더에서 sh 로
parsed=$(python3 - <<'PY' "$tab"
import re, sys
envs, jobs = [], {}
for line in sys.argv[1].splitlines():
    s = line.strip()
    if not s or s.startswith("#"):
        continue
    m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$", s)
    if m and not re.match(r"^[\d*@]", s):
        v = m.group(2)
        if len(v) >= 2 and v[0] == v[-1] and v[0] in "'\"":
            v = v[1:-1]
        envs.append(f"{m.group(1)}={v}")
        continue
    parts = s.split(None, 5)
    if len(parts) < 6:
        continue
    sched, cmd = " ".join(parts[:5]), parts[5]
    # cron: 이스케이프 안 된 % 는 줄바꿈 → 그 앞까지만 명령
    cmd = re.split(r"(?<!\\)%", cmd)[0].replace("\\%", "%")
    for key in ("cleanup.py", "daily_report.js"):
        if key in cmd and key not in jobs:
            jobs[key] = (sched, cmd)
for e in envs:
    print("ENV\t" + e)
for k, (sched, cmd) in jobs.items():
    print(f"JOB\t{k}\t{sched}\t{cmd}")
PY
)
envs=(); while IFS= read -r l; do envs+=("${l#ENV	}"); done < <(grep '^ENV	' <<< "$parsed")
job() { grep "^JOB	$1	" <<< "$parsed" | head -n 1; }
sched() { job "$1" | cut -f3; }
cmd() { job "$1" | cut -f4-; }
lastlog() { if [ -s "$1" ]; then tail -n 1 "$1" | cut -c1-120; else echo "로그 파일이 없거나 비어 있어요"; fi; }
run_like_cron() { (cd "$H" && runuser -u "$LEARNER" -- env -i HOME="$H" LOGNAME="$LEARNER" SHELL=/bin/sh PATH=/usr/bin:/bin "${envs[@]}" timeout 20 sh -c "$1" > /dev/null 2>&1); }

s=$(sched cleanup.py)
case "$s" in
  "*/30 * * * *"|"0,30 * * * *"|"00,30 * * * *"|"0-59/30 * * * *") pass "cleanup.py 가 30분마다 등록됐다" ;;
  *) fail "cleanup.py 가 30분마다 등록됐다 (지금: '${s:-등록 안 됨}')" ;;
esac
s=$(sched daily_report.js)
case "$s" in
  "30 7 * * *"|"30 07 * * *") pass "daily_report.js 가 매일 07:30 에 등록됐다" ;;
  *) fail "daily_report.js 가 매일 07:30 에 등록됐다 (지금: '${s:-등록 안 됨}')" ;;
esac

# cleanup: 오래된 파일 / 최근 파일을 만들어 두고 실행
keep=$(grep -o '"keep_days": [0-9]*' "$J/config.json" | grep -o '[0-9]*$')
mkdir -p "$J/tmp"; rm -f "$J/tmp/"cmdlab-*
touch -d "$((keep + 3)) days ago" "$J/tmp/cmdlab-old.tmp"; touch "$J/tmp/cmdlab-new.tmp"; chown "$LEARNER" "$J/tmp/"cmdlab-*
L="$J/logs/cleanup.log"; before=$(wc -l < "$L" 2>/dev/null || echo 0)
c=$(cmd cleanup.py)
[ -n "$c" ] && run_like_cron "$c"
if [ -n "$c" ] && [ ! -e "$J/tmp/cmdlab-old.tmp" ] && [ -e "$J/tmp/cmdlab-new.tmp" ]; then pass "cron 환경에서 cleanup.py 가 성공한다 (오래된 파일만 삭제)"
else fail "cron 환경에서 cleanup.py 가 성공한다 ($(lastlog "$L"))"; fi
after=$(wc -l < "$L" 2>/dev/null || echo 0)
[ "$after" -gt "$before" ] && grep -q '\[cleanup\]' "$L" 2>/dev/null \
  && pass "cleanup.py 출력이 ~/jobs/logs/cleanup.log 에 쌓인다" || fail "cleanup.py 출력이 ~/jobs/logs/cleanup.log 에 쌓인다 (>> 와 logs 폴더 확인)"
rm -f "$J/tmp/"cmdlab-*

# report: 오늘 보고서가 ~/daily-reports 에 생기는지
today=$(date -u +%F); R="$H/daily-reports/$today.txt"; rm -f "$R"
L="$J/logs/report.log"; before=$(wc -l < "$L" 2>/dev/null || echo 0)
c=$(cmd daily_report.js)
[ -n "$c" ] && run_like_cron "$c"
if [ -n "$c" ] && [ -f "$R" ]; then pass "cron 환경에서 daily_report.js 가 ~/daily-reports 에 보고서를 만든다"
else
  msg=$(lastlog "$L")
  case "$msg" in *작성*) msg="보고서가 엉뚱한 곳에 생겼어요: ${msg#\[report\] } — crontab 변수 줄에서는 \$HOME 이 풀리지 않아요" ;; esac
  fail "cron 환경에서 daily_report.js 가 ~/daily-reports 에 보고서를 만든다 ($msg)"
fi
after=$(wc -l < "$L" 2>/dev/null || echo 0)
[ "$after" -gt "$before" ] && grep -q '\[report\]' "$L" 2>/dev/null \
  && pass "daily_report.js 출력이 ~/jobs/logs/report.log 에 쌓인다" || fail "daily_report.js 출력이 ~/jobs/logs/report.log 에 쌓인다 (>> 와 logs 폴더 확인)"
# 로그는 덮어쓰지 않고 이어서: 한 번 더 실행하면 줄이 늘어야
before=$after; [ -n "$c" ] && run_like_cron "$c"; after=$(wc -l < "$L" 2>/dev/null || echo 0)
[ "$after" -gt "$before" ] && pass "로그를 덮어쓰지 않고 이어서 쓴다 (>>)" || fail "로그를 덮어쓰지 않고 이어서 쓴다 (> 대신 >>)"
finish
