#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/pricing"; mkdir -p "$R"; give "$R"
bad=$(rand_int 8 34)
as_learner bash -s <<SCRIPT
set -e
cd ~/pricing
git init -q
c() { GIT_AUTHOR_DATE="2026-09-\$(printf %02d \$((1 + \$1 / 2))) 1\$((\$1 % 10)):00:00" GIT_COMMITTER_DATE="2026-09-\$(printf %02d \$((1 + \$1 / 2))) 1\$((\$1 % 10)):00:00" git commit -qam "\$2"; }
cat > price.sh <<'EOF2'
#!/usr/bin/env bash
# 가격 계산 (원 단위 정수)
discount() { echo \$(( \$1 * (100 - \$2) / 100 )); }  # 할인가
tax() { echo \$(( \$1 * 110 / 100 )); }              # 부가세 포함
EOF2
cat > test.sh <<'EOF2'
#!/usr/bin/env bash
source ./price.sh
fail=0
[ "\$(discount 10000 20)" = 8000 ] && echo "✔ 할인가" || { echo "✘ 할인가: 10000원 20% 할인 = \$(discount 10000 20) (기대값 8000)"; fail=1; }
[ "\$(tax 10000)" = 11000 ] && echo "✔ 부가세" || { echo "✘ 부가세"; fail=1; }
exit \$fail
EOF2
chmod +x price.sh test.sh
echo "# pricing" > NOTES.md
git add . && c 0 "가격 계산 시작"
for i in \$(seq 1 39); do
  echo "- 메모 \$i" >> NOTES.md
  if [ \$i -eq $bad ]; then
    # 반올림 처리를 바꾸다 실수 (겉보기엔 리팩터링)
    sed -i 's|^discount() { echo \\\$(( \\\$1 \* (100 - \\\$2) / 100 )); }|discount() { echo \\\$(( (\\\$1 * (100 - \\\$2) - 1) / 100 )); }|' price.sh
  fi
  c \$i "\$(case \$((i % 4)) in 0) echo "리팩터링 \$i";; 1) echo "문서 정리 \$i";; 2) echo "코드 스타일 \$i";; 3) echo "작은 수정 \$i";; esac)"
done
SCRIPT
first_bad=$(git -C "$R" rev-list --reverse HEAD | sed -n "$((bad + 1))p")
secret_set bad "$first_bad"
git -C "$R" rev-parse HEAD > /opt/cmdlab/secret/head
