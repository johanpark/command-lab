#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
N="$H/my-notes"
mkdir -p "$N"
printf '# 리눅스 공부 노트\n\n- ls: 목록\n- cd: 이동\n- pwd: 현재 위치\n' > "$N/notes.md"
printf '# 할 일\n\n- [ ] git 배우기\n- [ ] 블로그 만들기\n' > "$N/todo.md"
echo "임시 메모 $(rand_int 1 999)" > "$N/scratch.tmp"
give "$N"
