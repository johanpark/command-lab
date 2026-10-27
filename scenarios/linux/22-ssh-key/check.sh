#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
K="$H/.ssh/id_ed25519"; D=/home/deploy/.ssh; AK="$D/authorized_keys"
fp=$(ssh-keygen -l -f "$K.pub" 2>/dev/null)
expect "~/.ssh/id_ed25519 (개인키)와 .pub (공개키)가 있다" test -f "$K" -a -f "$K.pub"
expect "ed25519 방식 키다" grep -q '(ED25519)' <<< "$fp"
expect "키 코멘트가 learner@lab 이다" bash -c "awk '{print \$3}' '$K.pub' | grep -qx 'learner@lab'"
mode=$(stat -c %a "$K" 2>/dev/null)
[ "$mode" = 600 ] && pass "개인키 권한이 600 이다" || fail "개인키 권한이 600 이다 (지금: ${mode:-없음})"
pub=$(awk '{print $1, $2}' "$K.pub" 2>/dev/null)
if [ -n "$pub" ] && [ -f "$AK" ] && awk '{print $1, $2}' "$AK" | grep -qxF "$pub"; then pass "내 공개키가 deploy 의 authorized_keys 에 등록됐다"
else fail "내 공개키가 deploy 의 authorized_keys 에 등록됐다"; fi
if [ -f "$AK" ] && grep -q 'PRIVATE KEY' "$AK"; then fail "authorized_keys 에 개인키가 들어가 있지 않다 (개인키는 절대 올리면 안 돼요!)"; fi
expect ".ssh 폴더: 소유자 deploy, 권한 700" test "$(stat -c '%U %a' "$D" 2>/dev/null)" = "deploy 700"
expect "authorized_keys: 소유자 deploy, 권한 600" test "$(stat -c '%U %a' "$AK" 2>/dev/null)" = "deploy 600"
finish
