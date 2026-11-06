# 설명: 압축된 .gz 로그는 grep 으로 못 찾는다 (zgrep 이 필요)
# 실패해야: 에러가 있는 로그 파일 이름
# 실패해야: incident.txt
order=$(grep -o 'ORD-[0-9]*' ~/request.txt)
file=$(grep -l "ERROR.*$order" ~/logs/* 2>/dev/null | head -n 1)
basename "${file:-none}" > ~/answer.txt
grep -B 2 "ERROR.*$order" ~/logs/* > ~/incident.txt 2>/dev/null
