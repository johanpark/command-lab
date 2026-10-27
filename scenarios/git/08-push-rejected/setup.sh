#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p /srv/git && chown "$LEARNER:$LEARNER" /srv/git
as_learner bash -s <<'SCRIPT'
set -e
git init -q --bare -b main /srv/git/team-app.git
c() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@team.kr" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@team.kr" git commit -qm "$2"; }
# 처음 저장소 내용
git clone -q /srv/git/team-app.git /tmp/seed 2>/dev/null
cd /tmp/seed
printf '# Team App\n' > README.md; printf 'export const version = "1.0";\n' > app.js
git add . && c 김팀장 "프로젝트 시작" && git push -q origin main
# 내가 clone
git clone -q /srv/git/team-app.git ~/team-app
# 동료가 먼저 push
cd /tmp/seed
printf 'export const login = () => {};\n' > login.js
git add . && c 이동료 "로그인 기능" && git push -q origin main
cd ~ && rm -rf /tmp/seed
# 내 커밋 (아직 push 안 함)
cd ~/team-app
printf '\n## 실행 방법\nnpm start\n' >> README.md
git commit -qam "README 에 실행 방법 추가"
SCRIPT
git -C /srv/git/team-app.git rev-parse main > /opt/cmdlab/secret/remote0
