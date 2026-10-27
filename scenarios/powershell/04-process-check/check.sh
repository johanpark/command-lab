#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
cpu=$(secret_get cpu); mem=$(secret_get mem)
expect_answer "mem.txt 에 메모리를 가장 많이 쓰는 프로세스 이름을 적었다" "$mem" "$H/mem.txt"
expect_answer "cpu.txt 에 CPU 를 가장 많이 쓴 프로세스 이름을 적었다" "$cpu" "$H/cpu.txt"
expect "$cpu 를 종료했다" bash -c "! pgrep -x '$cpu'"
expect "$mem(캐시)과 web-api 는 그대로 실행 중이다" bash -c "pgrep -x '$mem' && pgrep -x web-api"
finish
