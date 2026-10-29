#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "running.txt 에 실행 중인 인스턴스 수를 적었다" "$(cat /opt/cmdlab/secret/running)" "$H/running.txt"
expect_answer "answer.txt 에 payment-api 의 인스턴스 ID 를 적었다" "$(secret_get pay)"
F="$H/buckets.txt"
if [ ! -f "$F" ]; then fail "buckets.txt 에 버킷 이름이 모두 있다 (파일이 없어요)"
else
  # 'aws s3 ls' 출력을 그대로 저장한 경우도 이름 칸만 본다
  got=$(tr -d '\r' < "$F" | awk '{ print $NF }' | tr '\t' '\n' | sed '/^$/d' | sort -u)
  [ "$got" = "$(cat /opt/cmdlab/secret/buckets)" ] && pass "buckets.txt 에 버킷 이름이 모두 있다" \
    || fail "buckets.txt 에 버킷 이름이 모두 있다 (기대 $(wc -l < /opt/cmdlab/secret/buckets)개, 지금 $(echo "$got" | sed '/^$/d' | wc -l)개)"
fi
finish
