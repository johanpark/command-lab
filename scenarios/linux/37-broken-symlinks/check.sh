#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S="$H/site"
expect_answer "answer.txt 에 깨진 링크 개수를 적었다 (숨김 파일 포함)" "$(secret_get count)"
u="$S/releases/v3/uploads"
[ -L "$u" ] && [ "$(readlink "$u" | sed 's:/*$::')" = /srv/uploads ] && pass "releases/v3/uploads 가 /srv/uploads 를 가리킨다" \
  || fail "releases/v3/uploads 가 /srv/uploads 를 가리킨다 (지금: $( [ -L "$u" ] && readlink "$u" || echo 없음))"
left=$(find "$S" -xtype l | wc -l)
[ "$left" -eq 0 ] && pass "깨진 링크가 남아 있지 않다" || fail "깨진 링크가 남아 있지 않다 (${left}개 남음 — 숨김 파일?)"
good=$(find "$S" -type l ! -xtype l ! -path "$u" -printf '%P\t%l\n' | sort)
expect "정상 링크는 그대로다" test "$good" = "$(grep -v '^releases/v3/uploads	' /opt/cmdlab/secret/good)"
expect "진짜 파일은 그대로다" test "$(find "$S" -type f -printf '%P\n' | sort)" = "$(cat /opt/cmdlab/secret/files)"
finish
