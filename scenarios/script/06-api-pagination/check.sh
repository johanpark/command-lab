#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/users.json"
expect_answer "answer.txt 에 재직 중인 직원 수를 적었다" "$(node -e 'console.log(require("/opt/cmdlab/secret/users.json").filter((u) => u.active).length)')"
res=$(node - "$F" <<'JS'
const fs = require('fs');
const want = require('/opt/cmdlab/secret/users.json');
let got;
try { got = JSON.parse(fs.readFileSync(process.argv[2], 'utf8')); }
catch (e) { console.log('no\t~/users.json 이 올바른 JSON 이다 (' + (e.code === 'ENOENT' ? '파일이 없어요' : e.message.split('\n')[0]) + ')'); process.exit(); }
console.log('ok\t~/users.json 이 올바른 JSON 이다');
if (!Array.isArray(got)) { console.log('no\t하나의 JSON 배열이다 (지금: ' + (got === null ? 'null' : typeof got) + ' — {"data": ...} 를 그대로 저장했나요?)'); process.exit(); }
console.log('ok\t하나의 JSON 배열이다');
const ids = new Set(got.map((u) => u && u.id));
const missing = want.filter((u) => !ids.has(u.id)).length;
console.log((missing === 0 && got.length === want.length ? 'ok' : 'no') + `\t모든 직원이 한 번씩 들어 있다 (지금 ${got.length}명, 전체 ${want.length}명)`);
const byId = new Map(want.map((u) => [u.id, JSON.stringify(u)]));
const changed = got.filter((u) => u && byId.has(u.id) && byId.get(u.id) !== JSON.stringify(u)).length;
console.log((changed === 0 ? 'ok' : 'no') + `\t직원 정보가 API 가 준 그대로다${changed ? ` (${changed}명이 달라요)` : ''}`);
JS
)
while IFS=$'\t' read -r st msg; do [ "$st" = ok ] && pass "$msg" || fail "$msg"; done <<< "$res"
finish
