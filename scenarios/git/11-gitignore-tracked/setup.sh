#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/blog"; mkdir -p "$R"; give "$R"
key="sk_live_$(rand_int 100000 999999)"
as_learner bash -s <<SCRIPT
set -e
cd ~/blog
git init -q
c() { GIT_AUTHOR_DATE="\$1" GIT_COMMITTER_DATE="\$1" git commit -qm "\$2"; }
mkdir -p posts logs node_modules/marked node_modules/.bin
printf '# 나의 블로그\n' > index.md
printf '# 첫 글\n안녕하세요.\n' > posts/2026-09-01-hello.md
printf 'DB_PASSWORD=hunter2\nPAYMENT_KEY=$key\n' > .env
printf '2026-09-01 started\n' > logs/app.log
printf 'module.exports = {};\n' > node_modules/marked/index.js
printf '{"name":"marked"}\n' > node_modules/marked/package.json
printf '#!/bin/sh\n' > node_modules/.bin/marked
printf 'Bud1' > .DS_Store
git add . && c "2026-09-01T10:00:00" "블로그 시작"
printf '# 두 번째 글\nGit 공부 중.\n' > posts/2026-09-15-git.md
printf '2026-09-15 started\n' >> logs/app.log
git add . && c "2026-09-15T10:00:00" "두 번째 글"
printf '.env\nlogs/\nnode_modules/\n.DS_Store\n' > .gitignore
git add .gitignore && c "2026-10-01T10:00:00" ".gitignore 추가"
printf '2026-10-27 started\n' >> logs/app.log
SCRIPT
git -C "$R" rev-parse HEAD > /opt/cmdlab/secret/base
