`curl -s localhost:8080/api/users | jq 'del(.data)'` 로 데이터 말고 나머지를 보세요. `page`, `per_page`, `total`, `next` 가 있죠? `next` 가 **다음 페이지 주소**예요. 마지막 페이지에서는 `null` 이에요.
---
`per_page=1000` 처럼 크게 달라고 해도 서버가 **최대 50개**로 잘라요. 결국 `next` 를 따라가야 해요.
---
셸로: 
```bash
url="/api/users"; : > /tmp/pages.json
while [ "$url" != "null" ]; do
  body=$(curl -s "localhost:8080$url")
  echo "$body" | jq '.data' >> /tmp/pages.json
  url=$(echo "$body" | jq -r '.next')
done
jq -s 'add' /tmp/pages.json > ~/users.json
```
---
개수 확인: `jq length ~/users.json` 이 응답의 `total` 과 같아야 해요. 재직자: `jq '[.[] | select(.active)] | length' ~/users.json > ~/answer.txt`
