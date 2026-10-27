#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
P="$H/photos"; mkdir -p "$P"
start=$(rand_int 1 300); n=$(rand_int 15 25)
: > /opt/cmdlab/secret/names
for i in $(seq "$start" $((start + n - 1))); do
  b=$(printf 'IMG_%04d' "$i"); head -c 3000 /dev/urandom > "$P/$b.JPG"; echo "$b" >> /opt/cmdlab/secret/names
done
for b in "IMG_0100 (1)" "IMG_0100 (2)" "바다 노을"; do head -c 3000 /dev/urandom > "$P/$b.JPG"; echo "$b" >> /opt/cmdlab/secret/names; done
echo "3일차 사진은 흔들림이 많음" > "$P/notes.txt"
give "$P"
