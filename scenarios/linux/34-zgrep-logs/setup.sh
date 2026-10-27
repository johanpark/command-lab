#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
L="$H/logs"; mkdir -p "$L"
order="ORD-$(rand_int 100000 999999)"
day=$(rand_int 2 5)          # 에러가 난 로그: app.log.$day.gz
reason=$(rand_pick "card declined: insufficient funds" "card declined: expired card" "3DS authentication timeout")
secret_set order "$order"; secret_set file "app.log.$day.gz"
gen() { # $1=파일 번호 (0=오늘), $2=에러 포함 여부
  local d=$1 t
  t=$(date -d "$d days ago" +%F)
  for i in $(seq 1 400); do
    o="ORD-$(rand_int 100000 999999)"
    printf '%s %02d:%02d:%02d INFO  [order] created %s\n' "$t" $((i / 60 % 24)) $((i % 60)) $((i * 7 % 60)) "$o"
    if [ "$2" = yes ] && [ "$i" -eq 250 ]; then
      printf '%s 10:15:01 INFO  [order] created %s user=u%s amount=%s\n' "$t" "$order" "$(rand_int 1000 9999)" "$(rand_int 10 99)000"
      printf '%s 10:15:02 WARN  [payment] gateway retry 2/3 for %s: %s\n' "$t" "$order" "$reason"
      printf '%s 10:15:03 ERROR [payment] payment failed %s after 3 attempts\n' "$t" "$order"
    fi
  done
}
gen 0 no > "$L/app.log"; gen 1 no > "$L/app.log.1"
# 같은 주문 번호가 다른 날 로그에도 (조회 기록) 나오게
for d in 2 3 4 5 6; do
  gen "$d" "$([ "$d" -eq "$day" ] && echo yes || echo no)" > "$L/app.log.$d"
  [ "$d" -eq $((day + 1)) ] && echo "$(date -d "$d days ago" +%F) 09:00:00 INFO  [support] lookup $order" >> "$L/app.log.$d"
  gzip -f "$L/app.log.$d"
done
echo "$(date +%F) 11:00:00 INFO  [support] lookup $order (고객 문의)" >> "$L/app.log"
printf '고객 문의\n\n- 주문 번호: %s\n- 내용: 며칠 전 결제가 실패했어요\n' "$order" > "$H/request.txt"
zgrep -h -B 2 "ERROR.*$order" "$L/app.log.$day.gz" > /opt/cmdlab/secret/incident
give "$L" "$H/request.txt"
