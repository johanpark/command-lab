#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
name=$(secret_get name)
# 컨테이너의 root 는 SYS_PTRACE 가 없어 다른 사용자 소켓의 프로세스 이름을 못 본다 → 학습자로도 조회
owner() {
  local o
  o=$(ss -Hltnp "sport = :$1" 2>/dev/null | grep -o '(("[^"]*"' | head -n 1 | cut -d'"' -f2)
  [ -n "$o" ] || o=$(as_learner ss -Hltnp "sport = :$1" 2>/dev/null | grep -o '(("[^"]*"' | head -n 1 | cut -d'"' -f2)
  echo "$o"
}
expect_answer "answer.txt 에 8080 을 점유하던 프로세스 이름을 적었다" "$name"
expect "$name 프로세스가 종료됐다" bash -c "! pgrep -x '$name'"
o=$(owner 8080)
[ "$o" = myapp ] && pass "8080 포트에서 myapp 이 동작 중이다" || fail "8080 포트에서 myapp 이 동작 중이다 (지금: ${o:-아무것도 없음})"
o=$(owner 9100)
[ "$o" = metrics ] && pass "metrics(9100)는 그대로 동작 중이다" || fail "metrics(9100)는 그대로 동작 중이다 (지금: ${o:-아무것도 없음})"
finish
