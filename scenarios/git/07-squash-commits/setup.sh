#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/todo-app"
mkdir -p "$R"; give "$R"
as_learner bash -s <<'SCRIPT'
set -e
cd ~/todo-app
git init -q
c() { GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" git commit -qm "$2"; }
printf '# Todo App\n' > README.md
printf '<ul id="todos"></ul>\n' > index.html
git add . && c "2026-10-01T10:00:00" "프로젝트 시작"
printf 'function addTodo(t) { /* ... */ }\n' > app.js
git add . && c "2026-10-05T10:00:00" "할 일 추가 기능"
git switch -qc feature/login
printf '<form id="login">\n  <input name="id">\n  <input name="pw" type="password">\n</form>\n' > login.html
git add . && c "2026-10-20T10:00:00" "로그인 폼 추가"
printf 'function login(id, pw) {\n  return fetch("/api/login", { method: "POST" });\n}\n' > login.js
git add . && c "2026-10-20T15:00:00" "wip"
sed -i 's/name="pw"/name="password"/' login.html
git add . && c "2026-10-21T09:00:00" "오타 수정"
printf '\n// 로그인 후 할 일 목록으로 이동\nfunction afterLogin() { location.href = "/"; }\n' >> login.js
git add . && c "2026-10-21T18:00:00" "진짜 마지막 wip"
SCRIPT
git -C "$R" rev-parse main > /opt/cmdlab/secret/main
git -C "$R" rev-parse 'feature/login^{tree}' > /opt/cmdlab/secret/tree
