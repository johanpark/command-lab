#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
O="$H/onboarding"; rm -rf "$O" "$H/homes" "$H/created.txt"; mkdir -p "$O"
names=(김민수 이지은 박서준 최유나 정하늘 강도윤 조수아 윤지호 장예린 임태양 한소율 오준서)
accts=(mkim jlee sjpark ychoi hjung dkang sjo jyoon yjang tlim syhan jsoh)
depts=(플랫폼팀 결제팀 검색팀 모바일팀 데이터팀 디자인팀)
: > /opt/cmdlab/secret/expected
c2=$(rand_int 6 11)   # 취소자 두 명: 4번째와 무작위 한 명
{
  echo "Name,Account,Department,StartDate,Status"
  for i in "${!names[@]}"; do
    acc=${accts[$i]}; dep=${depts[$(rand_int 0 5)]}; st=confirmed
    shown=$acc
    case $((RANDOM % 4)) in
      0) shown="  $acc" ;;                                   # 앞 공백
      1) shown="$(tr '[:lower:]' '[:upper:]' <<< "${acc:0:1}")${acc:1} " ;;  # 첫 글자 대문자 + 뒤 공백
    esac
    if [ "$i" -eq 3 ] || [ "$i" -eq "$c2" ]; then st=cancelled; fi
    echo "${names[$i]},\"$shown\",$dep,2026-11-0$(rand_int 2 6),$st"
    [ "$st" = cancelled ] || printf '%s\t환영합니다, %s님! (%s)\n' "$acc" "${names[$i]}" "$dep" >> /opt/cmdlab/secret/expected
  done
} > "$O/new-hires.csv"
give "$O"
