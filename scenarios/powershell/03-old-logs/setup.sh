#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
L="$H/logs"
mkdir -p "$L"/{web,api,archive/2026}
: > /opt/cmdlab/secret/old; : > /opt/cmdlab/secret/keep
mk() { # 경로 일수
  echo "log line $RANDOM" > "$L/$1"
  touch -d "$2 days ago" "$L/$1"
  if [[ $1 == *.log ]] && [ "$2" -gt 30 ]; then echo "$L/$1" >> /opt/cmdlab/secret/old; else echo "$L/$1" >> /opt/cmdlab/secret/keep; fi
}
for d in web api; do
  for i in $(seq 1 $(rand_int 6 10)); do
    # 경계(30일 근처)는 피해서 애매하지 않게
    if [ $((RANDOM % 2)) -eq 0 ]; then age=$(rand_int 1 25); else age=$(rand_int 35 120); fi
    mk "$d/$d-$(printf %02d "$i").log" "$age"
  done
done
for i in $(seq 1 $(rand_int 4 8)); do mk "archive/2026/app-$i.log" "$(rand_int 40 200)"; done
mk "archive/2026/recent.log" 3
mk "web/nginx.conf" 300
mk "api/README.txt" 200
mk "archive/notes.txt" 90
give "$L"
