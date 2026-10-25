#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e

mkdir -p "$H/templates"
printf '# 나의 블로그\n\n생성일: %s\n' "$(date +%F)" > "$H/templates/README.md"
printf -- '---\ntitle: 첫 글\n---\n\n안녕하세요! 블로그를 시작했습니다. (%s)\n' "$(rand_int 1000 9999)" > "$H/draft.md"
md5sum < "$H/draft.md" | cut -d' ' -f1 > /opt/cmdlab/secret/draft.md5
echo "할 일: 블로그 폴더 정리" > "$H/todo.txt"
give "$H/templates" "$H/draft.md" "$H/todo.txt"
