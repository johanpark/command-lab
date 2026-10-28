#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
for g in developers deploy audit; do getent group "$g" >/dev/null || groupadd "$g"; done
id jun >/dev/null 2>&1 || useradd -m -s /bin/bash -G developers,audit jun
u=$(rand_pick minji seoyeon dohyun jiho haeun)
id "$u" >/dev/null 2>&1 && userdel -r "$u" 2>/dev/null || true
secret_set user "$u"
O="$H/onboarding"; mkdir -p "$O"
ssh-keygen -q -t ed25519 -N '' -C "$u@laptop" -f "/opt/cmdlab/secret/$u"
cp "/opt/cmdlab/secret/$u.pub" "$O/$u.pub"
cat > "$O/request.txt" <<REQ
[계정 요청] 신입 개발자 서버 계정

- 이름: 신입 개발자
- 계정: $u
- 셸: bash
- 그룹: developers
- SSH 공개키: 같은 폴더의 $u.pub

추가 요청: jun 님에게 배포 권한(deploy 그룹)도 부탁드려요.
REQ
give "$O"
