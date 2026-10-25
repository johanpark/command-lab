# /etc/profile.d/cmdlab.sh — 로그인 셸마다 실행된다.

# docker exec 는 umask 가 0000 일 수 있어 일반 리눅스와 같게 맞춘다
umask 022

# 입력한 명령어를 즉시 기록 (채점 후 '내가 입력한 명령어'로 보여주기 위함)
if [ -n "$BASH_VERSION" ]; then
  export HISTTIMEFORMAT='%F %T  '
  shopt -s histappend
  case "$PROMPT_COMMAND" in
    *"history -a"*) ;;
    *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
  esac
fi

# 대화형 셸에서만 안내 문구 출력
if [ -r /opt/cmdlab/run/env ] && [[ $- == *i* ]]; then
  # shellcheck disable=SC1091
  . /opt/cmdlab/run/env
  printf '\n\033[1;36m[%s]\033[0m %s\n' "$SCENARIO_ID" "$SCENARIO_TITLE"
  printf '  \033[33mtask\033[0m 문제 다시 보기 · \033[33mhint\033[0m 힌트 · \033[33mcheck\033[0m 채점 · \033[33mexit\033[0m 나가기\n\n'
fi
