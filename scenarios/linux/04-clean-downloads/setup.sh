#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
D="$H/Downloads"
mkdir -p "$D"
make() { head -c "$(rand_int 200 4000)" /dev/urandom > "$D/$1"; }
for n in IMG_2031 IMG_2032 IMG_2040 "여행 사진 1" "여행 사진 2" screenshot_0412; do make "$n.jpg"; done
make "DSC_0099.JPG"
for n in logo banner "diagram final" icon-32; do make "$n.png"; done
for n in invoice_2026-03 "회의록 4월" manual resume_v2 tax-report; do make "$n.pdf"; done
for i in $(seq 1 $(rand_int 4 8)); do make "download_$RANDOM.tmp"; done
make "~lock.tmp"
for n in project-backup photos-2025; do make "$n.zip"; done
give "$D"
# 채점용: 원래 파일 목록 저장
(cd "$D" && ls -1) > /opt/cmdlab/secret/files.txt
