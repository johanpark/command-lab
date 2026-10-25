#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
big=$(secret_get big)
got=$(answer)
got=${got/#\~/$H}
if [ "$got" = "$big" ]; then pass "answer.txt 에 가장 큰 파일의 경로를 적었다"
else fail "answer.txt 에 가장 큰 파일의 경로를 적었다 (지금 적힌 값: '$(answer)')"; fi
expect "가장 큰 파일을 삭제했다" test ! -e "$big"
lost=0
while IFS= read -r f; do [ -e "$f" ] || lost=$((lost + 1)); done < /opt/cmdlab/secret/keep
[ "$lost" -eq 0 ] && pass "다른 파일은 그대로 있다" || fail "다른 파일은 그대로 있다 (${lost}개 사라짐!)"
finish
