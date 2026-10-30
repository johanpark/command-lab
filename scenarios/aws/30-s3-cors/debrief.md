# 해설

```json
{"CORSRules": [{
  "AllowedOrigins": ["https://shop.example", "https://admin.shop.example"],
  "AllowedMethods": ["GET", "PUT"],
  "AllowedHeaders": ["Content-Type"],
  "ExposeHeaders": ["ETag"],
  "MaxAgeSeconds": 3000
}]}
```
`aws s3api put-bucket-cors --bucket shop-uploads-XXXX --cors-configuration file://cors.json`

## 프리플라이트 흐름
```
브라우저 → S3:  OPTIONS /avatars/u123.png
                Origin: https://shop.example
                Access-Control-Request-Method: PUT
                Access-Control-Request-Headers: content-type
S3 → 브라우저:  Access-Control-Allow-Origin: https://shop.example     ← AllowedOrigins 에 있어야
                Access-Control-Allow-Methods: GET, PUT                ← AllowedMethods
                Access-Control-Allow-Headers: content-type            ← AllowedHeaders
                Access-Control-Expose-Headers: ETag                   ← ExposeHeaders
                Access-Control-Max-Age: 3000                          ← 이 답을 3000초 동안 기억
브라우저 → S3:  PUT (진짜 요청)
```

## 자주 하는 오해
- **CORS 는 보안 장치가 아니라 "브라우저에게 주는 허락"** 이에요. curl 이나 서버에서는 CORS 와 상관없이 요청이 가요. 그래서 CORS 를 연다고 버킷이 공개되는 게 아니고, 접근 권한은 여전히 미리 서명된 URL·IAM 이 결정해요.
- 그렇다고 `AllowedOrigins: ["*"]` 를 쓰면, 아무 사이트의 JS 가 사용자의 브라우저를 통해 이 버킷에 요청할 수 있게 돼요. 운영에서는 **정확한 도메인**만.
- `ExposeHeaders` 를 안 넣으면 응답은 오는데 JS 에서 `response.headers.get('ETag')` 가 `null` 이에요. 멀티파트 업로드에서 자주 막히는 곳.

## 실무 팁
- CloudFront 를 앞에 두면 CloudFront 쪽에서도 `Origin` 헤더를 S3 로 넘기도록(캐시 키 포함) 설정해야 CORS 가 제대로 동작해요.
- 개발용 localhost 는 **개발용 버킷**에만 두고, 운영 버킷 설정은 Terraform 등으로 관리해서 섞이지 않게 하세요.
