#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_cell "count.txt: 10월 결제 건수 (31일, 1일 0시 포함 / 9월·11월 제외)" "$(secret_get count)" "$H/count.txt"
expect_cell "total.txt: 10월 결제 금액 합계" "$(secret_get total)" "$H/total.txt"
finish
