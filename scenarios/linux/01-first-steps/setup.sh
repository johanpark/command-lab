#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e

code=$(rand_pick sunflower blueberry penguin marathon lighthouse octopus waterfall)-$(rand_int 100 999)
secret_set code "$code"

mkdir -p "$H"/projects/{alpha/src,alpha/tests,beta/docs,beta/src,gamma/data/2025,gamma/data/2026}
echo "projects 폴더 안 어딘가에 메모를 남겼어요. 'docs' 폴더를 찾아보세요." > "$H/README.txt"
echo "alpha 프로젝트: 메모 없음" > "$H/projects/alpha/README.txt"
echo "print('hello')" > "$H/projects/alpha/src/main.py"
echo "beta 프로젝트 문서는 docs 폴더에" > "$H/projects/beta/README.txt"
printf '인수인계 메모\n\n오늘의 암호: %s\n\n- 전임자\n' "$code" > "$H/projects/beta/docs/memo.txt"
echo "회의록: 특이사항 없음" > "$H/projects/beta/docs/meeting.txt"
echo "id,value" > "$H/projects/gamma/data/2026/numbers.csv"
give "$H/projects" "$H/README.txt"
