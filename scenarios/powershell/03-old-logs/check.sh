#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 30일보다 오래된 .log 개수를 적었다" "$(wc -l < /opt/cmdlab/secret/old)"
left=0; while IFS= read -r f; do [ -e "$f" ] && left=$((left + 1)); done < /opt/cmdlab/secret/old
[ "$left" -eq 0 ] && pass "오래된 .log 파일을 모두 지웠다" || fail "오래된 .log 파일을 모두 지웠다 (${left}개 남음 — 하위 폴더까지 봤나요?)"
lost=0; while IFS= read -r f; do [ -e "$f" ] || lost=$((lost + 1)); done < /opt/cmdlab/secret/keep
[ "$lost" -eq 0 ] && pass "최근 로그와 .log 가 아닌 파일은 그대로다" || fail "최근 로그와 .log 가 아닌 파일은 그대로다 (${lost}개 사라짐!)"
finish
