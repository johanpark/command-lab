#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
P="$H/project"; T="$H/backups/project-today.tar.gz"
expect "src/config.js 가 복구됐다" grep -q "$(secret_get key)" "$P/src/config.js"
expect "백업 이후 수정한 파일들은 최신 상태 그대로다" md5sum --quiet -c /opt/cmdlab/secret/latest.md5
if ! tar -tzf "$T" >/dev/null 2>&1; then
  fail "~/backups/project-today.tar.gz 가 올바른 tar.gz 파일이다 (없거나 깨졌어요)"
else
  pass "~/backups/project-today.tar.gz 가 올바른 tar.gz 파일이다"
  list=$(tar -tzf "$T")
  expect "새 백업에 node_modules 가 없다" bash -c "! grep -q node_modules <<< \"\$1\"" _ "$list"
  expect "새 백업에 src/app.js, src/util.js, src/config.js 가 들어 있다" bash -c \
    'for f in src/app.js src/util.js src/config.js; do grep -qE "(^|/)$f\$" <<< "$1" || exit 1; done' _ "$list"
fi
finish
