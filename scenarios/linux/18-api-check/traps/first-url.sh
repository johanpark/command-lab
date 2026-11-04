# 설명: 상태 코드를 확인하지 않고 첫 주소를 적는다
# 실패해야: 고장 난(200 이 아닌) 주소
head -n 1 ~/endpoints.txt > ~/answer.txt
curl -s http://localhost:8000/api/users.json | jq -r '.[] | select(.role == "admin") | .email' > ~/admins.txt
