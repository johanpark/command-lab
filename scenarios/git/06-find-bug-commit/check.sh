#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/calculator"
g() { git -C "$R" "$@"; }
bug=$(secret_get bug); got=$(answer)
if [ "${#got}" -ge 7 ] && [ "${bug#"$got"}" != "$bug" ]; then pass "answer.txt 에 버그를 만든 커밋 해시를 적었다"
else fail "answer.txt 에 버그를 만든 커밋 해시를 적었다 (지금 적힌 값: '$got' — 앞 7자리 이상)"; fi
expect "기존 커밋 기록이 그대로다 (기록을 지우거나 고쳐 쓰지 않음)" g merge-base --is-ancestor "$(secret_get head)" HEAD
expect "add 가 다시 a + b 다" grep -qF 'add() { echo $(( $1 + $2 )); }' "$R/calc.sh"
expect "그 뒤에 추가된 pow(거듭제곱)는 살아 있다" grep -q '^pow()' "$R/calc.sh"
expect "./test.sh 가 모두 통과한다" as_learner bash -c "cd '$R' && ./test.sh"
if g log --format=%s "$(secret_get head)..HEAD" | grep -q '^Revert'; then pass "git revert 로 되돌렸다"
else fail "git revert 로 되돌렸다 (직접 고친 커밋 대신 git revert <해시> 를 써 보세요)"; fi
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
