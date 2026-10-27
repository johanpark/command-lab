while read -r url; do
  [ "$(curl -s -o /dev/null -w '%{http_code}' "$url")" = 200 ] || echo "$url" > ~/answer.txt
done < ~/endpoints.txt
curl -s http://localhost:8000/api/users.json | jq -r '.[] | select(.role == "admin") | .email' > ~/admins.txt
