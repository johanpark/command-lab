#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
B=shop-uploads-$(rand_int 1000 9999); secret_set bucket "$B"
aws s3 mb "s3://$B" >/dev/null
aws s3api put-public-access-block --bucket "$B" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-cors --bucket "$B" --cors-configuration \
  '{"CORSRules":[{"AllowedOrigins":["http://localhost:3000"],"AllowedMethods":["GET"],"AllowedHeaders":["Authorization"],"MaxAgeSeconds":60}]}'
mkdir -p "$H"
cat > "$H/cors-error.txt" <<TXT
[브라우저 콘솔 — https://shop.example/mypage/profile]

Access to fetch at 'https://$B.s3.ap-northeast-2.amazonaws.com/avatars/u123.png?X-Amz-Signature=...'
from origin 'https://shop.example' has been blocked by CORS policy:
Response to preflight request doesn't pass access control check:
No 'Access-Control-Allow-Origin' header is present on the requested resource.

[프론트엔드 개발자 메모]
- 업로드: 미리 서명된 URL 로 PUT, 헤더 Content-Type 을 보냄
- 업로드 후 응답 헤더의 ETag 를 읽어서 서버에 알려 줌 (지금은 브라우저가 ETag 를 못 읽음)
- 보기: GET
- 사이트 주소: https://shop.example, 관리자 https://admin.shop.example
- localhost:3000 은 개발용이라 운영 버킷에서는 빼 달라고 보안팀 요청
TXT
give "$H/cors-error.txt"
