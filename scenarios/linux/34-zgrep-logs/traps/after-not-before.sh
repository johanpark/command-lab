# 설명: -A 2 는 뒤 2줄이다 (바로 앞 2줄은 -B 2)
# 실패해야: 앞 2줄
order=$(grep -o 'ORD-[0-9]*' ~/request.txt)
file=$(zgrep -l "ERROR.*$order" ~/logs/*)
basename "$file" > ~/answer.txt
zgrep -A 2 "ERROR.*$order" "$file" > ~/incident.txt
