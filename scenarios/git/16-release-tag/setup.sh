#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
rm -rf "$H/app" "$H/remote"; mkdir -p "$H/remote"; give "$H/remote"
as_learner bash -s <<'SCRIPT'
set -e
cd ~/remote && git init -q --bare -b main app.git
git clone -q ~/remote/app.git ~/app 2>/dev/null
cd ~/app
n=0
c() { n=$((n + 1)); d="2026-10-$(printf %02d $n)T10:00:00"; GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" git commit -qm "$1"; }
echo "1.0.0" > VERSION; echo "app" > app.js; git add . && c "첫 릴리스 준비"
echo "// 검색" >> app.js; git commit -qam "검색 기능" --date="2026-10-02T10:00:00"
echo "1.1.0" > VERSION; GIT_COMMITTER_DATE="2026-10-03T10:00:00" git commit -qam "버전 1.1.0" --date="2026-10-03T10:00:00"
GIT_COMMITTER_DATE="2026-10-03T11:00:00" git tag -a v1.1.0 -m "1.1.0 릴리스"
for m in "장바구니 개선" "결제 수단 추가" "버그 수정: 쿠폰 계산"; do echo "// $m" >> app.js; git commit -qam "$m"; done
echo "1.2.0" > VERSION; git commit -qam "버전 1.2.0"
for m in "다국어 지원 시작" "추천 기능 초안" "README 정리"; do echo "// $m" >> app.js; git commit -qam "$m"; done
git push -q origin main v1.1.0 2>/dev/null
SCRIPT
git -C "$H/app" log --format=%H --grep='^버전 1.2.0$' > /opt/cmdlab/secret/release
