#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/my-notes"
g() { git -C "$R" "$@"; }
expect "~/my-notes 가 Git 저장소다" test -d "$R/.git"
expect "커밋이 하나 이상 있다" g rev-parse --verify HEAD
expect "notes.md 가 커밋돼 있다" g cat-file -e HEAD:notes.md
expect "todo.md 가 커밋돼 있다" g cat-file -e HEAD:todo.md
expect "scratch.tmp 는 커밋되지 않았다" bash -c "! git -C '$R' cat-file -e HEAD:scratch.tmp"
expect "커밋하지 않은 변경 사항이 없다 (untracked 제외)" test -z "$(g status --porcelain --untracked-files=no 2>/dev/null)"
finish
