#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B="$H/blog"
expect "~/blog 폴더가 있다" test -d "$B"
expect "~/blog/posts, images, drafts 폴더가 있다" test -d "$B/posts" -a -d "$B/images" -a -d "$B/drafts"
expect "~/blog/images 는 비어 있다" test -z "$(ls -A "$B/images" 2>/dev/null)"
expect "~/blog/README.md 가 템플릿과 내용이 같다" cmp -s "$B/README.md" "$H/templates/README.md"
expect "원본 ~/templates/README.md 는 그대로 있다" test -f "$H/templates/README.md"
if [ -f "$B/posts/2026-hello.md" ] && [ "$(md5sum < "$B/posts/2026-hello.md" | cut -d' ' -f1)" = "$(secret_get draft.md5)" ]; then
  pass "~/blog/posts/2026-hello.md 가 원래 draft.md 내용이다"
else
  fail "~/blog/posts/2026-hello.md 가 원래 draft.md 내용이다"
fi
expect "~/draft.md 는 더 이상 홈에 없다 (복사가 아니라 이동)" test ! -e "$H/draft.md"
expect "~/blog/drafts/ideas.md 파일이 있다" test -f "$B/drafts/ideas.md"
finish
