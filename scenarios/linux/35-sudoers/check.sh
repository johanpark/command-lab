#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F=/etc/sudoers.d/deploy
expect "/etc/sudoers.d/deploy 파일이 있다" test -f "$F"
expect "sudoers 문법이 올바르다 (visudo -c)" visudo -c
mode=$(stat -c %a "$F" 2>/dev/null)
[ "$mode" = 440 ] && pass "파일 권한이 0440 이다" || fail "파일 권한이 0440 이다 (지금: ${mode:-없음})"
rm -f /var/run/app-restarted
runuser -u deploy -- sudo -n /usr/local/bin/app-restart >/dev/null 2>&1
expect "deploy 가 비밀번호 없이 sudo app-restart 를 실행할 수 있다" test -f /var/run/app-restarted
expect "deploy 는 다른 명령(cat /etc/shadow)을 sudo 로 실행할 수 없다" bash -c '! runuser -u deploy -- sudo -n cat /etc/shadow'
expect "deploy 는 sudo 로 셸을 얻을 수 없다 (bash)" bash -c '! runuser -u deploy -- sudo -n bash -c true'
# 위 두 가지만 막고 vim·tee·ALL 같은 다른 명령을 열어 두면 결국 root 를 얻을 수 있다 → 허용 목록 전체를 본다
extra=$(sudo -l -U deploy 2>/dev/null | sed -n '/may run the following/,$p' | tail -n +2 \
  | sed -E 's/^[[:space:]]*\([^)]*\)[[:space:]]*//; s/^([A-Z_]+:[[:space:]]*)+//' | tr ',' '\n' \
  | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | grep . | grep -vE '^/usr/local/bin/app-restart( |$)' | sort -u | paste -sd' ')
[ -z "$extra" ] && pass "deploy 가 sudo 로 할 수 있는 건 app-restart 하나뿐이다 (sudo -l -U deploy)" \
  || fail "deploy 가 sudo 로 할 수 있는 건 app-restart 하나뿐이다 (그 밖에 허용된 것: $extra — sudo 그룹에 넣었거나 다른 명령을 같이 적었나요?)"
grep -q app-restart "$F" 2>/dev/null && pass "규칙이 /etc/sudoers.d/deploy 에 있다" || fail "규칙이 /etc/sudoers.d/deploy 에 있다 (다른 파일에 적었나요?)"
finish
