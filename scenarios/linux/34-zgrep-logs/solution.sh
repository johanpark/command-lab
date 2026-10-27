order=$(grep -o 'ORD-[0-9]*' ~/request.txt)
file=$(zgrep -l "ERROR.*$order" ~/logs/*)
basename "$file" > ~/answer.txt
zgrep -B 2 "ERROR.*$order" "$file" > ~/incident.txt
