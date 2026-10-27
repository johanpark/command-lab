#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
name=$(secret_get name)
expect_answer "answer.txt 에 지워진 파일을 붙잡은 프로세스 이름을 적었다" "$name"
pid=$(pgrep -x "$name" | head -n 1)
expect "$name 은 종료하지 않고 그대로 실행 중이다" test -n "$pid"
if [ -n "$pid" ]; then
  # 컨테이너의 root 는 다른 사용자의 /proc/PID/fd 를 못 봐서 학습자 권한으로 확인
  size=$(as_learner stat -L -c %s "/proc/$pid/fd/3" 2>/dev/null || echo 999999999)
  [ "$size" -lt 1000000 ] && pass "지워진 로그가 차지하던 공간을 비웠다 (지금 ${size}바이트)" || fail "지워진 로그가 차지하던 공간을 비웠다 (아직 $((size / 1000000))MB)"
fi
finish
