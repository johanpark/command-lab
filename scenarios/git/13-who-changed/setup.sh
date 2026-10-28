#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/api"; rm -rf "$R"; mkdir -p "$R"; give "$R"
bad=$(rand_int 6 18)
as_learner bash -s <<SCRIPT
set -e
cd ~/api
git init -q
authors=("김민수:minsu" "이지은:jieun" "박서준:seojun" "최유나:yuna" "정하늘:haneul")
n=0
c() { # 메시지 [작성자 인덱스]
  n=\$((n + 1))
  a=\${authors[\$(( \${2:-\$n} % 5 ))]}
  d="2026-09-\$(printf %02d \$(( (n % 28) + 1 )))T1\$((n % 10)):00:00"
  GIT_AUTHOR_NAME="\${a%%:*}" GIT_AUTHOR_EMAIL="\${a##*:}@corp.example" GIT_COMMITTER_NAME="\${a%%:*}" GIT_COMMITTER_EMAIL="\${a##*:}@corp.example" \
    GIT_AUTHOR_DATE="\$d" GIT_COMMITTER_DATE="\$d" git commit -qam "\$1"
}
cat > config.js <<'JS'
module.exports = {
  API_URL: 'https://pay.internal/api',
  TIMEOUT_MS: 3000,
  RETRIES: 3,
  LOG_LEVEL: 'info',
};
JS
echo "// 결제 API 클라이언트" > client.js
git add . && c "결제 API 설정 추가"
for i in \$(seq 1 24); do
  echo "// 변경 \$i" >> client.js
  if [ \$i -eq $bad ]; then
    sed -i 's/TIMEOUT_MS: 3000,/TIMEOUT_MS: 300,/; s/RETRIES: 3,/RETRIES: 5,/' config.js
    c "재시도 횟수 늘리고 설정 정리" \$((i * 7))
  elif [ \$i -eq 20 ]; then
    sed -i 's/^  /    /' config.js     # 들여쓰기 2칸 → 4칸
    git commit -qam "코드 포맷 정리 (prettier)" --author="format-bot <bot@corp.example>" --date="2026-10-20T10:00:00"
  else
    c "\$(case \$((i % 4)) in 0) echo "클라이언트 로그 개선 \$i";; 1) echo "에러 메시지 다듬기 \$i";; 2) echo "주석 정리 \$i";; 3) echo "리팩터링 \$i";; esac)"
  fi
done
SCRIPT
git -C "$R" log --format=%H -S 'TIMEOUT_MS: 300,' | tail -n 1 > /opt/cmdlab/secret/culprit
git -C "$R" rev-parse HEAD > /opt/cmdlab/secret/head
git -C "$R" show HEAD:config.js | sed 's/TIMEOUT_MS: 300,/TIMEOUT_MS: 3000,/' > /opt/cmdlab/secret/fixed.js
