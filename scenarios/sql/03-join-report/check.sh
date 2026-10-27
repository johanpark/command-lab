#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_cell "answer.txt 에 총 구매액 1위 고객 이름을 적었다" "$(secret_get top)"
expect_cell "never.txt 에 주문한 적 없는 고객 수를 적었다" "$(secret_get never)" "$H/never.txt"
expect_cell "category.txt 에 매출 1위 카테고리를 적었다" "$(secret_get category)" "$H/category.txt"
finish
