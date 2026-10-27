#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/shop"; mkdir -p "$R"; give "$R"
limit=$(rand_int 3 10)
as_learner bash -s <<SCRIPT
set -e
cd ~/shop
git init -q
c() { GIT_AUTHOR_DATE="\$1" GIT_COMMITTER_DATE="\$1" git commit -qm "\$2"; }
printf 'export function login(id, pw) {\n  return check(id, pw);\n}\n' > login.js
printf '# shop\n' > README.md
git add . && c "2026-09-01T10:00:00" "쇼핑몰 1.0"
git branch release/1.0
printf 'export const coupon = () => {};\n' > coupon.js
git add . && c "2026-10-02T10:00:00" "쿠폰 기능 (개발 중)"
printf 'export const recommend = () => [];\n' > recommend.js
git add . && c "2026-10-05T10:00:00" "추천 기능 초안"
printf 'let fails = 0;\nexport function login(id, pw) {\n  if (fails >= $limit) throw new Error("too many attempts");\n  return check(id, pw);\n}\n' > login.js
git commit -qam "보안: 로그인 시도 횟수 제한 ($limit회)" --date="2026-10-08T10:00:00"
printf '\n## 개발 중\n- 쿠폰\n- 추천\n' >> README.md
git commit -qam "README 개발 현황" --date="2026-10-09T10:00:00"
git switch -q main
SCRIPT
git -C "$R" rev-parse release/1.0 > /opt/cmdlab/secret/release
git -C "$R" rev-parse main > /opt/cmdlab/secret/main
git -C "$R" show main:login.js > /opt/cmdlab/secret/login.js
