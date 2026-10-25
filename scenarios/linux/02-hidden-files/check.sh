#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 실제 설정(.env)의 DB_PORT 를 적었다" "$(secret_get port)"
finish
