#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 ERROR 줄 개수를 적었다" "$(secret_get count)"
expect "~/recent.log 에 마지막 20줄이 저장됐다" cmp -s "$H/recent.log" /opt/cmdlab/secret/recent
expect "~/errors.log 에 ERROR 줄만 모두 저장됐다" cmp -s "$H/errors.log" /opt/cmdlab/secret/errors
finish
