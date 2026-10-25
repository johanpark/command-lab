#!/usr/bin/env bash
# 컨테이너 생성 직후 root로 한 번 실행된다: 실습 공통 도구/권한을 준비한다.
# (LEARNER, LEARNER_HOME, SCENARIO_ID, SCENARIO_TITLE, HISTORY_FILE 은 엔진이 넘겨준다)
set -euo pipefail
L=/opt/cmdlab

# Windows에서 체크아웃해 CRLF가 섞여 들어와도 동작하도록 정리
find "$L/lib" "$L/scenario" -type f \( -name '*.sh' -o -name '*.md' -o -path "$L/lib/bin/*" \) \
  -exec sed -i 's/\r$//' {} +

chmod 755 "$L" "$L/lib" "$L/lib/bin" "$L/scenario"
chmod 755 "$L"/lib/bin/*
# 정답/채점 로직은 학습자에게 보이지 않게
for f in setup.sh check.sh solution.sh solution.ps1 debrief.md; do
  if [ -e "$L/scenario/$f" ]; then chmod 600 "$L/scenario/$f"; fi
done

mkdir -p "$L/run" "$L/secret"
chmod 1777 "$L/run"
chmod 700 "$L/secret"

{
  printf 'LEARNER=%q\n' "$LEARNER"
  printf 'LEARNER_HOME=%q\n' "$LEARNER_HOME"
  printf 'SCENARIO_ID=%q\n' "$SCENARIO_ID"
  printf 'SCENARIO_TITLE=%q\n' "$SCENARIO_TITLE"
  printf 'HISTORY_FILE=%q\n' "$HISTORY_FILE"
} > "$L/run/env"
chmod 644 "$L/run/env"

# 컨테이너 안에서 쓰는 도우미 명령: task / hint / check
for f in "$L"/lib/bin/*; do ln -sf "$f" "/usr/local/bin/$(basename "$f")"; done
if [ -d /etc/profile.d ]; then cp "$L/lib/profile.sh" /etc/profile.d/cmdlab.sh; fi
