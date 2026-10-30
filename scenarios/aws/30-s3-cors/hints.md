지금 설정: `aws s3api get-bucket-cors --bucket shop-uploads-XXXX` → localhost 에서 GET 만 허용하는 개발용 설정이에요.
---
`put-bucket-cors` 는 **통째로 교체**예요. 필요한 걸 다 넣은 JSON 을 새로 쓰세요. `vim cors.json` → `jq . cors.json` 으로 문법 확인.
---
- `AllowedOrigins`: 두 주소를 **정확히** (`https://` 포함, 끝에 `/` 없이)
- `AllowedMethods`: `["GET", "PUT"]`
- `AllowedHeaders`: `["Content-Type"]` (프리플라이트에서 브라우저가 "이 헤더 보내도 돼?" 라고 묻는 것)
- `ExposeHeaders`: `["ETag"]` (브라우저 JS 가 응답에서 읽을 수 있는 헤더)
