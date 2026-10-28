#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
tab=$(crontab -u "$LEARNER" -l 2>/dev/null | sed -e 's/#.*//' -e '/^[[:space:]]*$/d')
# 스크립트별로 해당 줄의 시간 필드 5개를 꺼낸다
# 앞자리 0(03 → 3)과 대소문자(MON → mon)는 같은 뜻이라 정리해서 비교한다
fields() { awk -v s="scripts/$1.sh" 'index($0, s) { print $1, $2, $3, $4, $5; exit }' <<< "$tab" | sed -E 's/(^|[^0-9])0+([0-9])/\1\2/g'; }
lower() { tr '[:upper:]' '[:lower:]'; }

f=$(fields backup)
[ "$f" = "30 3 * * *" ] && pass "backup.sh: 매일 03:30" || fail "backup.sh: 매일 03:30 (지금: '${f:-등록 안 됨}')"

f=$(fields report | lower)
case "$f" in
  "0 9 * * 1-5"|"0 9 * * mon-fri"|"0 9 * * 1,2,3,4,5")
    pass "report.sh: 평일 09:00" ;;
  *) fail "report.sh: 평일 09:00 (지금: '${f:-등록 안 됨}')" ;;
esac

f=$(fields health)
case "$f" in
  "*/5 * * * *"|"0-59/5 * * * *"|"0,5,10,15,20,25,30,35,40,45,50,55 * * * *")
    pass "health.sh: 5분마다" ;;
  *) fail "health.sh: 5분마다 (지금: '${f:-등록 안 됨}')" ;;
esac
finish
