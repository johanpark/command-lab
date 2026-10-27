#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
pw=$(getent passwd kim)
expect "사용자 kim 이 있다" test -n "$pw"
expect "kim 의 홈 폴더 /home/kim 이 있다" bash -c "[ \"\$(cut -d: -f6 <<< '$pw')\" = /home/kim ] && [ -d /home/kim ]"
expect "kim 의 셸이 /bin/bash 다" test "$(cut -d: -f7 <<< "$pw")" = /bin/bash
expect "그룹 webdev 가 있다" getent group webdev
in_group() { id -nG "$1" 2>/dev/null | tr ' ' '\n' | grep -qx "$2"; }
expect "learner 가 webdev 에 속한다" in_group learner webdev
expect "kim 이 webdev 에 속한다" in_group kim webdev
expect "learner 는 여전히 designers 에도 속한다 (-a 를 빼먹지 않음)" in_group learner designers
expect "/srv/website 의 그룹이 webdev 다" test "$(stat -c %G /srv/website)" = webdev
mode=$(stat -c %a /srv/website)
[ "$mode" = 2770 ] && pass "/srv/website 권한이 2770 (drwxrws---)" || fail "/srv/website 권한이 2770 (drwxrws---) (지금: $mode)"
finish
