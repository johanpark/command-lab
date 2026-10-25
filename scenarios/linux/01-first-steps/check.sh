#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 메모의 암호를 적었다" "$(secret_get code)"
finish
