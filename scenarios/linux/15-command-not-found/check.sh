#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
# 새 터미널을 연 것처럼 로그인+대화형 셸에서 확인한다
fresh() { as_learner bash -lic "$1" 2>/dev/null < /dev/null; }
where=$(fresh 'type -P deploytool' | tail -n 1)
[ "$where" = "$H/tools/bin/deploytool" ] && pass "새 터미널에서도 deploytool 을 이름만으로 실행할 수 있다" \
  || fail "새 터미널에서도 deploytool 을 이름만으로 실행할 수 있다 (~/.bashrc 에 PATH 설정을 저장했나요?)"
ok=$(fresh 'type -P ls >/dev/null && type -P grep >/dev/null && echo yes' | tail -n 1)
[ "$ok" = yes ] && pass "새 터미널에서 ls, grep 도 잘 동작한다" || fail "새 터미널에서 ls, grep 도 잘 동작한다 (PATH 를 덮어쓰지 않았는지 확인: \$PATH: 를 앞에 붙여야 해요)"
expect_answer "answer.txt 에 deploytool --version 결과를 적었다" "$(secret_get ver)"
finish
