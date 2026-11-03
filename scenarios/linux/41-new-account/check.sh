#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
u=$(secret_get user)
if ! id "$u" >/dev/null 2>&1; then fail "$u 계정이 있다"; else
  pass "$u 계정이 있다"
  IFS=: read -r _ _ _ _ _ home shell <<< "$(getent passwd "$u")"
  [ "$home" = "/home/$u" ] && [ -d "$home" ] && [ "$(stat -c %U "$home")" = "$u" ] && pass "홈 폴더 /home/$u 가 있고 $u 소유다" \
    || fail "홈 폴더 /home/$u 가 있고 $u 소유다 (useradd -m 을 썼나요?)"
  [ "$shell" = /bin/bash ] && pass "로그인 셸이 /bin/bash 다" || fail "로그인 셸이 /bin/bash 다 (지금: ${shell:-없음})"
  expect "$u 가 developers 그룹에 있다" bash -c "id -nG '$u' | tr ' ' '\n' | grep -qx developers"
  more=$(id -nG "$u" 2>/dev/null | tr ' ' '\n' | grep -vxE "$u|developers" | paste -sd' ')
  [ -z "$more" ] && pass "$u 계정은 요청받은 그룹에만 있다" || fail "$u 계정은 요청받은 그룹에만 있다 (요청에 없는 그룹: $more — 신입에게 필요 이상의 권한이에요)"
  S="/home/$u/.ssh"; K="$S/authorized_keys"
  if [ -f "$K" ] && grep -qF "$(cut -d' ' -f1,2 "/opt/cmdlab/secret/$u.pub")" "$K"; then pass "authorized_keys 에 공개키가 들어 있다"
  else fail "authorized_keys 에 공개키가 들어 있다 ($( [ -f "$K" ] && echo '키가 달라요' || echo '파일이 없어요'))"; fi
  got="$(stat -c '%a %U' "$S" 2>/dev/null) / $(stat -c '%a %U' "$K" 2>/dev/null)"
  [ "$got" = "700 $u / 600 $u" ] && pass ".ssh 700, authorized_keys 600, 둘 다 $u 소유다" \
    || fail ".ssh 700, authorized_keys 600, 둘 다 $u 소유다 (지금: $got)"
  mode=$(stat -c %a "/home/$u" 2>/dev/null)
  [ -n "$mode" ] && [ $(( 8#$mode & 8#022 )) -eq 0 ] && pass "홈 폴더를 다른 사람이 쓸 수 없다" || fail "홈 폴더를 다른 사람이 쓸 수 없다 (지금: ${mode:-없음})"
fi
g=$(id -nG jun 2>/dev/null | tr ' ' '\n' | sort | tr '\n' ' ')
echo "$g" | grep -qw deploy && pass "jun 이 deploy 그룹에 들어갔다" || fail "jun 이 deploy 그룹에 들어갔다 (지금: $g)"
more=$(id -nG jun 2>/dev/null | tr ' ' '\n' | grep -vxE 'jun|developers|audit|deploy' | paste -sd' ')
[ -z "$more" ] && pass "jun 에게 요청받지 않은 그룹은 없다" || fail "jun 에게 요청받지 않은 그룹은 없다 (지금 더 있는 것: $more)"
echo "$g" | grep -qw developers && echo "$g" | grep -qw audit && pass "jun 의 원래 그룹(developers, audit)이 그대로다" \
  || fail "jun 의 원래 그룹(developers, audit)이 그대로다 (지금: $g — usermod 에 -a 를 빼먹었나요?)"
finish
