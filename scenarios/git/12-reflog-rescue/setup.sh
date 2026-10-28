#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/app"; mkdir -p "$R"; give "$R"
as_learner bash -s <<'SCRIPT'
set -e
cd ~/app
git init -q
n=0
c() { n=$((n + 1)); d="2026-10-$(printf %02d $n)T1$((n % 10)):00:00"; GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" git commit -qm "$1"; }
echo "# app" > README.md; git add .; c "프로젝트 시작"
echo "login" > login.js; git add .; c "로그인 화면"
git switch -q -c feature/payment
echo "pay" > payment.js; git add .; c "결제 모듈"
echo "retry" >> payment.js; git commit -qam "결제 실패 재시도" --date="2026-10-04T10:00:00"
git switch -q main
echo "signup" > signup.js; git add .; c "회원가입"
echo "profile" > profile.js; git add .; c "프로필 수정"
echo "i18n" > i18n.js; git add .; c "다국어 지원"
SCRIPT
git -C "$R" rev-parse main > /opt/cmdlab/secret/main
git -C "$R" rev-parse feature/payment > /opt/cmdlab/secret/payment
as_learner bash -c 'cd ~/app && git branch -q -D feature/payment && git reset -q --hard HEAD~3'
