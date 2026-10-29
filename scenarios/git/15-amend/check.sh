#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
L="$H/blog"; B="$H/remote/blog.git"; base=$(cat /opt/cmdlab/secret/base)
g() { git -C "$L" "$@"; }
n=$(g rev-list --count "$base..main" 2>/dev/null)
[ "$n" = 1 ] && pass "push 안 했던 커밋이 여전히 하나다 (새 커밋을 덧붙이지 않음)" || fail "push 안 했던 커밋이 여전히 하나다 (지금 ${n:-?}개 — 커밋을 더 만들지 말고 --amend)"
msg=$(g log -1 --format=%s main 2>/dev/null)
[ "$msg" = "로그인 페이지 추가" ] && pass "커밋 메시지가 '로그인 페이지 추가' 다" || fail "커밋 메시지가 '로그인 페이지 추가' 다 (지금: '$msg')"
css=$(g show main:login.css 2>/dev/null | md5sum | cut -d' ' -f1); html=$(g show main:login.html 2>/dev/null | md5sum | cut -d' ' -f1)
[ "$css" = "$(cat /opt/cmdlab/secret/css)" ] && [ "$html" = "$(cat /opt/cmdlab/secret/html)" ] && pass "그 커밋에 login.html 과 login.css 가 함께 들어 있다" \
  || fail "그 커밋에 login.html 과 login.css 가 함께 들어 있다 (git show --stat HEAD 로 확인)"
expect "앞선 커밋 기록은 그대로다" test "$(g rev-parse 'main^' 2>/dev/null)" = "$base"
expect "고친 커밋을 원격 main 에 push 했다" test "$(git -C "$B" rev-parse main 2>/dev/null)" = "$(g rev-parse main 2>/dev/null)"
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
