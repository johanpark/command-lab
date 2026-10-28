#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
big=$(secret_get big)
# 경로 표기를 너그럽게: du 의 '크기<탭>경로', ~/..., ./..., 홈이나 ~/app 기준 상대 경로 모두 인정
path_ok() {
  local p
  p=$(answer | tail -n 1 | awk '{ print $NF }')
  p=${p/#\~/$H}; p=${p#./}
  [ "$p" = "$big" ] || [ "$H/$p" = "$big" ] || [ "$H/app/$p" = "$big" ]
}
if path_ok; then pass "answer.txt 에 가장 큰 파일의 경로를 적었다"
else fail "answer.txt 에 가장 큰 파일의 경로를 적었다 (지금 적힌 값: '$(answer)')"; fi
expect "가장 큰 파일을 삭제했다" test ! -e "$big"
lost=0
while IFS= read -r f; do [ -e "$f" ] || lost=$((lost + 1)); done < /opt/cmdlab/secret/keep
[ "$lost" -eq 0 ] && pass "다른 파일은 그대로 있다" || fail "다른 파일은 그대로 있다 (${lost}개 사라짐!)"
finish
