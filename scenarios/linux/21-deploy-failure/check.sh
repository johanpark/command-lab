#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
C="$H/app/config/app.env"
expect "학습자가 설정 파일을 읽을 수 있다" as_learner test -r "$C"
mode=$(stat -c %a "$C" 2>/dev/null)
if [ -n "$mode" ] && [ $(( 8#$mode & 8#022 )) -eq 0 ]; then pass "설정 파일을 아무나 고칠 수 있게 열어 두지 않았다 ($mode)"
else fail "설정 파일을 아무나 고칠 수 있게 열어 두지 않았다 (지금: ${mode:-없음} — 그룹/다른 사람 쓰기 권한 제거)"; fi
expect "PORT 가 9000 이다" grep -qx 'PORT=9000' "$C"
expect "DOC_ROOT 가 실제 있는 폴더를 가리킨다" bash -c "source '$C' 2>/dev/null; [ -d \"\$DOC_ROOT\" ] && [ -f \"\$DOC_ROOT/health\" ]"
expect "shop-server 가 실행 중이다" pgrep -x shop-server
got=$(curl -fs http://localhost:9000/health 2>/dev/null)
[ "$got" = ok ] && pass "헬스 체크(http://localhost:9000/health)가 ok 를 돌려준다" || fail "헬스 체크(http://localhost:9000/health)가 ok 를 돌려준다 (./deploy.sh 를 다시 실행했나요?)"
finish
