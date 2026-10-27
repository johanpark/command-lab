#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/pricing"; g() { git -C "$R" "$@"; }
bad=$(secret_get bad); got=$(answer)
if [ "${#got}" -ge 7 ] && [ "${bad#"$got"}" != "$bad" ]; then pass "answer.txt 에 처음 깨진 커밋 해시를 적었다"
else fail "answer.txt 에 처음 깨진 커밋 해시를 적었다 (지금 적힌 값: '$got')"; fi
expect "bisect 가 끝났다 (git bisect reset)" test ! -e "$R/.git/BISECT_LOG"
expect "main 브랜치의 원래 위치에 있다" bash -c "[ \"\$(git -C '$R' branch --show-current)\" = main ] && [ \"\$(git -C '$R' rev-parse HEAD)\" = '$(secret_get head)' ]"
finish
