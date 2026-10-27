# shellcheck shell=bash
# 시나리오의 setup.sh / check.sh 맨 위에서 source 해서 쓰는 공통 함수 모음.
#   source /opt/cmdlab/lib/helpers.sh

# shellcheck disable=SC1091
source /opt/cmdlab/run/env
: "${LEARNER:=learner}"
: "${LEARNER_HOME:=/home/$LEARNER}"
H="$LEARNER_HOME"
umask 022

# ---------- setup.sh 용 ----------

# 학습자 권한으로 명령 실행 (HOME도 학습자 홈으로)
as_learner() {
  (cd "$H" && runuser -u "$LEARNER" -- env HOME="$H" USER="$LEARNER" LOGNAME="$LEARNER" "$@")
}

# 파일/디렉터리 소유자를 학습자로
give() { chown -R "$LEARNER:$LEARNER" "$@"; }

# 무작위 정답 등을 학습자에게 보이지 않는 곳에 저장/조회
secret_set() { printf '%s' "$2" > "/opt/cmdlab/secret/$1"; }
secret_get() { cat "/opt/cmdlab/secret/$1" 2>/dev/null; }

# 인자 중 하나를 무작위로 고른다: rand_pick a b c
rand_pick() { local items=("$@"); echo "${items[RANDOM % ${#items[@]}]}"; }
# min~max 사이 정수: rand_int 10 99
rand_int() { echo $(( $1 + RANDOM % ($2 - $1 + 1) )); }

# 학습자가 실행해도 출력/종료를 기다리지 않는 백그라운드 프로세스 시작
spawn_bg() { as_learner setsid nohup "$@" >/dev/null 2>&1 < /dev/null & }

# ---------- check.sh 용 ----------
# 각 항목은 ✔/✘ 한 줄로 출력되고, 하나라도 실패하면 종료 코드가 1이 된다.

_cmdlab_failed=0
pass() { echo "✔ $*"; }
fail() { echo "✘ $*"; _cmdlab_failed=1; }

# expect "설명" 명령 [인자...]  → 명령이 성공하면 통과
expect() {
  local msg=$1; shift
  if "$@" >/dev/null 2>&1; then pass "$msg"; else fail "$msg"; fi
}

# 답안 파일 내용(앞뒤 공백/빈 줄/CR 제거). 기본 파일: ~/answer.txt
answer() {
  local f="${1:-$H/answer.txt}"
  [ -f "$f" ] || return 1
  tr -d '\r' < "$f" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d'
}

# expect_answer "설명" "기대값" [답안파일]
expect_answer() {
  local msg=$1 expected=$2 file=${3:-$H/answer.txt} got
  if [ ! -f "$file" ]; then fail "$msg (답안 파일 $(pretty_path "$file") 이 없어요)"; return; fi
  got=$(answer "$file")
  if [ "$got" = "$expected" ]; then pass "$msg"; else fail "$msg (지금 적힌 값: '${got}')"; fi
}

# sqlite3 등이 출력한 표(box/column/list, 머리글 포함)를 그대로 저장한 답안에서
# 마지막 값 한 칸만 꺼낸다. 예: "│ 12 │" → 12
cell_answer() {
  local f="${1:-$H/answer.txt}"
  [ -f "$f" ] || return 1
  tr -d '\r' < "$f" | sed 's/[│┃|]/ /g' | grep -vE '^[[:space:]─━┌┐└┘├┤┬┴┼+=-]*$' | tail -n 1 \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# expect_cell "설명" "기대값" [답안파일]
expect_cell() {
  local msg=$1 expected=$2 file=${3:-$H/answer.txt} got
  if [ ! -f "$file" ]; then fail "$msg (답안 파일 $(pretty_path "$file") 이 없어요)"; return; fi
  got=$(cell_answer "$file")
  if [ "$got" = "$expected" ]; then pass "$msg"; else fail "$msg (지금 적힌 값: '${got}')"; fi
}

# /home/learner/x → ~/x 로 보기 좋게
pretty_path() { if [[ $1 == "$H"/* ]]; then echo "~${1#"$H"}"; else echo "$1"; fi; }

finish() { exit "$_cmdlab_failed"; }
