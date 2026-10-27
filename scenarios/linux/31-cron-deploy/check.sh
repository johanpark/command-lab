#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
rm -f "$H/site/build.txt"
for dir in / /tmp; do
  out=$(cd "$dir" && runuser -u "$LEARNER" -- env -i HOME="$H" PATH=/usr/bin:/bin bash "$H/deploy/nightly.sh" 2>&1); rc=$?
  if [ $rc -eq 0 ] && [ "$(cat "$H/site/build.txt" 2>/dev/null)" = "$(date +%F)" ]; then
    pass "$dir 에서 cron 같은 환경(env -i, PATH=/usr/bin:/bin)으로 실행해도 성공한다"
  else
    fail "$dir 에서 cron 같은 환경(env -i, PATH=/usr/bin:/bin)으로 실행해도 성공한다 ($(tail -n 1 <<< "$out"))"
  fi
  rm -f "$H/site/build.txt"
done
expect "설정과 빌드 파일은 원래 자리에 있다" test -f "$H/deploy/config/deploy.env" -a -f "$H/deploy/dist/index.html" -a -x "$H/.local/bin/notify"
# 터미널에서 직접 실행하는 것처럼 로그인 셸(.profile 의 PATH 포함)로
expect "~/deploy 에서 직접 실행해도 여전히 성공한다" as_learner bash -lc 'cd ~/deploy && ./nightly.sh'
finish
