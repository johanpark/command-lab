#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "~/www 에 2.5.0 이 배포됐다" 2.5.0 "$H/www/version.txt"
# 실패에 엄격한지: 산출물이 없는 버전으로 실행해 본다 (임시 홈에서, 실제 배포에 영향 없게)
T=$(mktemp -d); mkdir -p "$T/build" "$T/www"; chown -R "$LEARNER:$LEARNER" "$T"
out=$(cd "$T" && runuser -u "$LEARNER" -- env HOME="$T" bash "$H/deploy.sh" 9.9.9 2>&1); rc=$?
rm -rf "$T"
if [ $rc -ne 0 ] && ! grep -q '배포 성공' <<< "$out"; then pass "단계가 실패하면 즉시 멈추고 0 이 아닌 종료 코드로 끝난다"
else fail "단계가 실패하면 즉시 멈추고 0 이 아닌 종료 코드로 끝난다 (없는 버전으로 실행했더니 종료 코드 $rc$(grep -q '배포 성공' <<< "$out" && echo ', \"배포 성공\" 출력'))"; fi
expect "빌드 산출물 이름은 그대로다 (스크립트를 고쳤다)" test -f "$H/build/app-v2.5.0.tar.gz"
finish
