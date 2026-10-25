#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
name=$(secret_get name)
expect_answer "answer.txt 에 범인 프로세스 이름을 적었다" "$name"
expect "$name 프로세스가 종료됐다" bash -c "! pgrep -x '$name'"
expect "web-server 는 계속 실행 중이다" pgrep -x web-server
expect "log-shipper 는 계속 실행 중이다" pgrep -x log-shipper
finish
