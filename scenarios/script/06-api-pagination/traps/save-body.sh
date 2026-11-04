# 설명: 응답 본문({data, next})을 그대로 저장하면 직원 배열이 아니다
# 실패해야: 하나의 JSON 배열
curl -s 'http://localhost:8080/api/users?per_page=50' > ~/users.json
