#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 원래 풀리던(옛) IP 를 적었다" "$(secret_get old)"
ip=$(getent hosts api.internal | awk '{print $1; exit}')
[ "$ip" = 127.0.0.1 ] && pass "api.internal 이 127.0.0.1 로 풀린다" || fail "api.internal 이 127.0.0.1 로 풀린다 (지금: ${ip:-못 찾음})"
[ "$(curl -fs -m 3 http://api.internal:8000/health 2>/dev/null)" = ok ] && pass "curl http://api.internal:8000/health 가 ok 다" || fail "curl http://api.internal:8000/health 가 ok 다"
lost=0; while IFS= read -r l; do grep -qxF "$l" /etc/hosts || lost=$((lost + 1)); done < /opt/cmdlab/secret/hosts.keep
[ "$lost" -eq 0 ] && pass "/etc/hosts 의 다른 줄은 그대로다" || fail "/etc/hosts 의 다른 줄은 그대로다 (${lost}줄 사라짐)"
finish
