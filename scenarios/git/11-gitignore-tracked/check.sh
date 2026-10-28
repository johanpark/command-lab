#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/blog"; g() { git -C "$R" "$@"; }
tree=$(g ls-tree -r --name-only HEAD 2>/dev/null)
bad=$(grep -E '^(\.env|logs/|node_modules/|\.DS_Store)' <<< "$tree" | tr '\n' ' ')
[ -z "$bad" ] && pass "마지막 커밋에 .env, logs/, node_modules/, .DS_Store 가 없다" || fail "마지막 커밋에 .env, logs/, node_modules/, .DS_Store 가 없다 (아직 있음: $bad)"
expect "블로그 글과 .gitignore 는 저장소에 남아 있다" bash -c "for f in index.md posts/2026-09-01-hello.md posts/2026-09-15-git.md .gitignore; do grep -qx \"\$f\" <<< \"\$1\" || exit 1; done" _ "$tree"
missing=""
for f in .env logs/app.log node_modules/marked/index.js .DS_Store; do [ -e "$R/$f" ] || missing+="$f "; done
[ -z "$missing" ] && pass "실제 파일은 지워지지 않았다" || fail "실제 파일은 지워지지 않았다 (사라짐: $missing— --cached 를 빼먹었나요?)"
expect ".gitignore 규칙이 그대로 적용된다" test "$(g check-ignore .env logs/app.log node_modules/marked/index.js .DS_Store 2>/dev/null | wc -l)" = 4
expect "기존 커밋 기록은 그대로다 (그 위에 새 커밋)" bash -c "git -C '$R' merge-base --is-ancestor '$(cat /opt/cmdlab/secret/base)' HEAD && [ \"\$(git -C '$R' rev-parse HEAD)\" != '$(cat /opt/cmdlab/secret/base)' ]"
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
