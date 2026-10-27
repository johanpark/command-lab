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
finish
