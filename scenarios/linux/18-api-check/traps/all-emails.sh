# 설명: role 을 거르지 않으면 모든 사용자 email 이 들어간다
# 실패해야: admin 사용자 email
while read -r url; do
  [ "$(curl -s -o /dev/null -w '%{http_code}' "$url")" = 200 ] || echo "$url" > ~/answer.txt
done < ~/endpoints.txt
curl -s http://localhost:8000/api/users.json | jq -r '.[].email' > ~/admins.txt
