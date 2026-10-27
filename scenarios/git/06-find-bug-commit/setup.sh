#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/calculator"
mkdir -p "$R"; give "$R"
as_learner bash -s <<'SCRIPT'
set -e
cd ~/calculator
git init -q
c() { # 작성자 날짜 메시지
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@team.kr" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@team.kr" \
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -qam "$3"
}
cat > calc.sh <<'EOF2'
#!/usr/bin/env bash
# 계산기 함수 모음
add() { echo $(( $1 + $2 )); }
sub() { echo $(( $1 - $2 )); }
EOF2
cat > test.sh <<'EOF2'
#!/usr/bin/env bash
source ./calc.sh
t() { local got; got=$("$1" "$2" "$3"); if [ "$got" = "$4" ]; then echo "✔ $1"; else echo "✘ $1: $2 $5 $3 = $got (기대값 $4)"; fail=1; fi; }
fail=0
t add 2 3 5 +
t sub 7 4 3 -
exit $fail
EOF2
chmod +x calc.sh test.sh
echo "# calculator" > README.md
git add . && c 김민수 "2026-10-01T10:00:00" "계산기 시작"
printf 'mul() { echo $(( $1 * $2 )); }\n' >> calc.sh
sed -i 's/^t sub 7 4 3 -$/t sub 7 4 3 -\nt mul 3 4 12 x/' test.sh
c 이지연 "2026-10-03T11:00:00" "곱셈 추가"
echo "사용법: source calc.sh" >> README.md
c 김민수 "2026-10-05T09:30:00" "README 사용법"
printf 'div() { [ "$2" -eq 0 ] && { echo "0으로 나눌 수 없음"; return 1; }; echo $(( $1 / $2 )); }\n' >> calc.sh
sed -i 's/^t mul 3 4 12 x$/t mul 3 4 12 x\nt div 8 2 4 \//' test.sh
c 박개발 "2026-10-08T14:00:00" "나눗셈 추가"
# 범인 커밋: 주석 정리와 함께 슬쩍 덧셈을 망가뜨림
sed -i 's/^# 계산기 함수 모음$/# 계산기 함수 모음 (정수 전용)/; s/^add() { echo \$(( \$1 + \$2 )); }$/add() { echo $(( $1 - $2 )); }/' calc.sh
c 박개발 "2026-10-12T16:20:00" "코드 스타일 정리"
echo "기여 방법: PR 환영" >> README.md
c 이지연 "2026-10-15T10:00:00" "README 기여 방법"
printf 'pow() { echo $(( $1 ** $2 )); }\n' >> calc.sh
sed -i 's/^exit \$fail$/t pow 2 10 1024 ^\nexit $fail/' test.sh
c 최신입 "2026-10-20T13:00:00" "거듭제곱 추가"
echo "*.log" > .gitignore && git add .gitignore
c 김민수 "2026-10-22T09:00:00" "gitignore"
SCRIPT
git -C "$R" log --format=%H --grep='코드 스타일 정리' > /opt/cmdlab/secret/bug
git -C "$R" rev-parse HEAD > /opt/cmdlab/secret/head
