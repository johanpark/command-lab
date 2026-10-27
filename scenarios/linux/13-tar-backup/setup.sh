#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
P="$H/project"; B="$H/backups"
mkdir -p "$P"/{src,docs,node_modules/{lodash,express,react}} "$B"
key="key_$(rand_int 100000 999999)"
secret_set key "$key"
# 백업 시점의 프로젝트
echo "module.exports = { apiKey: '$key', region: 'ap-northeast-2' };" > "$P/src/config.js"
echo "console.log('v1');" > "$P/src/app.js"
echo "# 문서 v1" > "$P/docs/guide.md"
echo '{ "name": "project", "version": "1.0.0" }' > "$P/package.json"
for m in lodash express react; do for i in $(seq 1 20); do head -c 20000 /dev/urandom > "$P/node_modules/$m/file$i.js"; done; done
tar -czf "$B/project-2026-10-20.tar.gz" -C "$H" project
touch -d '2026-10-20 18:00' "$B/project-2026-10-20.tar.gz"
# 백업 이후의 작업
rm "$P/src/config.js"
echo "console.log('v2 - 새 기능 추가');" > "$P/src/app.js"
echo "# 문서 v2 (최신)" > "$P/docs/guide.md"
echo "export const util = 1;" > "$P/src/util.js"
echo '{ "name": "project", "version": "2.0.0" }' > "$P/package.json"
give "$P" "$B"
md5sum "$P/src/app.js" "$P/docs/guide.md" "$P/package.json" "$P/src/util.js" > /opt/cmdlab/secret/latest.md5
