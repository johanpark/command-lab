#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "count.txt 에 /app/payment-api 의 OutOfMemoryError 건수를 적었다" "$(cat /opt/cmdlab/secret/oom)" "$H/count.txt"
expect_answer "answer.txt 에 에러가 난 서버(로그 스트림) 이름을 적었다" "$(secret_get bad)"
finish
