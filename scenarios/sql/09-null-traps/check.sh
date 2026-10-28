#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_cell "no_phone.txt: 전화번호가 없는 회원 수 (NULL + 빈 문자열)" "$(secret_get no_phone)" "$H/no_phone.txt"
expect_cell "never_referrer.txt: 추천인으로 한 번도 안 뽑힌 회원 수" "$(secret_get never)" "$H/never_referrer.txt"
expect_cell "avg_points.txt: NULL 을 0점으로 친 평균 포인트" "$(secret_get avg)" "$H/avg_points.txt"
finish
