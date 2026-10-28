#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/api"; g() { git -C "$R" "$@"; }
bad=$(cat /opt/cmdlab/secret/culprit); got=$(answer)
if [ "${#got}" -ge 7 ] && [ "${bad#"$got"}" != "$bad" ]; then pass "answer.txt 에 3000 → 300 으로 바꾼 커밋 해시를 적었다"
else
  who=$(g log -1 --format='%an: %s' "$got" 2>/dev/null)
  fail "answer.txt 에 3000 → 300 으로 바꾼 커밋 해시를 적었다 (지금: '$got'${who:+ = $who})"
fi
if g show HEAD:config.js 2>/dev/null | cmp -s - /opt/cmdlab/secret/fixed.js; then pass "config.js 의 TIMEOUT_MS 가 3000 으로 돌아왔다 (다른 설정은 그대로)"
else fail "config.js 의 TIMEOUT_MS 가 3000 으로 돌아왔다 (다른 설정은 그대로) (마지막 커밋 기준: $(g show HEAD:config.js 2>/dev/null | grep -o 'TIMEOUT_MS: [0-9]*'))"; fi
head0=$(cat /opt/cmdlab/secret/head)
expect "기존 기록은 그대로 두고 새 커밋으로 고쳤다" bash -c "git -C '$R' merge-base --is-ancestor $head0 HEAD && [ \"\$(git -C '$R' rev-parse HEAD)\" != $head0 ]"
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
