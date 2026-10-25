#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 요청이 가장 많은 IP를 적었다" "$(secret_get top)"
# top5.txt: 공백 차이는 무시. 횟수가 순서대로 맞고, 각 (횟수, IP) 쌍이 실제 집계에 있으면 통과 (동점 순서는 상관없음)
top5_ok() {
  local got want
  got=$(awk 'NF { print $1, $2 }' "$H/top5.txt")
  [ "$(echo "$got" | wc -l)" -eq 5 ] || return 1
  want=$(head -n 5 /opt/cmdlab/secret/ranking | awk '{print $1}')
  [ "$(echo "$got" | awk '{print $1}')" = "$want" ] || return 1
  while read -r n ip; do
    awk -v n="$n" -v ip="$ip" '$1 == n && $2 == ip { found = 1 } END { exit !found }' /opt/cmdlab/secret/ranking || return 1
  done <<< "$got"
}
if [ ! -f "$H/top5.txt" ]; then
  fail "~/top5.txt 에 상위 5개 IP와 횟수가 있다 (파일이 없어요)"
elif top5_ok; then
  pass "~/top5.txt 에 상위 5개 IP와 횟수가 있다"
else
  fail "~/top5.txt 에 상위 5개 IP와 횟수가 있다 (5줄, '횟수 IP' 형식, 많은 순서인지 확인)"
fi
finish
