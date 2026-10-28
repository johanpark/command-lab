#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
if ! docker image inspect webapp:1.1 >/dev/null 2>&1; then fail "webapp:1.1 이미지가 있다"; finish; fi
pass "webapp:1.1 이미지가 있다"
ls=$(docker run --rm --entrypoint ls webapp:1.1 -a /app 2>/dev/null)
bad=""; for x in .env .git node_modules logs; do grep -qx "$x" <<< "$ls" && bad+="$x "; done
grep -qx .env <<< "$ls" && fail ".env(비밀번호)가 이미지에 없다 (숨김 파일도 .dockerignore 에 적었나요?)" || pass ".env(비밀번호)가 이미지에 없다"
[ -z "$(sed 's/\.env //' <<< "$bad")" ] && pass ".git, node_modules, logs 가 이미지에 없다" || fail ".git, node_modules, logs 가 이미지에 없다 (아직 있음: $(sed 's/\.env //' <<< "$bad"))"
size=$(docker image inspect -f '{{.Size}}' webapp:1.1)
mb=$(( size / 1024 / 1024 ))
[ "$size" -lt $((10 * 1024 * 1024)) ] && pass "이미지가 10MB 미만이다 (${mb}MB)" || fail "이미지가 10MB 미만이다 (지금 ${mb}MB)"
got=$(docker run --rm --entrypoint cat webapp:1.1 /app/public/index.html 2>/dev/null)
[ "$got" = "<h1>Hello from webapp</h1>" ] && pass "웹사이트 파일(public/index.html)이 그대로 들어 있다" || fail "웹사이트 파일(public/index.html)이 그대로 들어 있다"
finish
