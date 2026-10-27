`cat ~/endpoints.txt` 로 주소 목록을 보고, `curl -i <주소>` 로 하나씩 열어 보세요. 첫 줄의 `HTTP/1.1 200 OK` 같은 부분이 상태 코드예요.
---
반복문으로 한 번에: `while read url; do echo "$(curl -s -o /dev/null -w '%{http_code}' "$url") $url"; done < ~/endpoints.txt`
---
JSON 구조 먼저 보기: `curl -s http://localhost:8000/api/users.json | jq '.[0]'`. 각 사용자가 `name`, `email`, `role` 을 갖고 있어요.
---
`curl -s http://localhost:8000/api/users.json | jq -r '.[] | select(.role == "admin") | .email' > ~/admins.txt`. `-r` 이 없으면 이메일에 따옴표가 붙어요!
