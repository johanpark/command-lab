#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/recipes"
g() { git -C "$R" "$@"; }
expect "kimchi.md 가 마지막 커밋 상태로 돌아왔다" cmp -s "$R/kimchi.md" /opt/cmdlab/secret/kimchi
expect "bulgogi.md 가 되살아났다" cmp -s "$R/bulgogi.md" /opt/cmdlab/secret/bulgogi
if g show HEAD:bibimbap.md 2>/dev/null | cmp -s - /opt/cmdlab/secret/bibimbap; then
  pass "bibimbap.md 를 지워지기 직전 내용(비법 포함)으로 되살려 커밋했다"
elif g cat-file -e HEAD:bibimbap.md 2>/dev/null; then
  fail "bibimbap.md 를 지워지기 직전 내용(비법 포함)으로 되살려 커밋했다 (커밋은 됐지만 내용이 달라요. 너무 예전 커밋에서 꺼내지 않았나요?)"
else
  fail "bibimbap.md 를 지워지기 직전 내용(비법 포함)으로 되살려 커밋했다"
fi
expect "기존 커밋 기록은 그대로다" g merge-base --is-ancestor "$(secret_get head)" HEAD
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
