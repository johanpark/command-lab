#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_cell "answer.txt 에 서울 고객 수를 적었다" "$(secret_get seoul)"
expect_cell "expensive.txt 에 가장 비싼 상품 이름을 적었다" "$(secret_get expensive)" "$H/expensive.txt"
expect_cell "october.txt 에 2026년 10월 주문 수를 적었다" "$(secret_get october)" "$H/october.txt"
finish
