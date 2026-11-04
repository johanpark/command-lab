# 설명: AllowedOrigins 를 * 로 열면 아무 사이트에서나 업로드할 수 있다
# 실패해야: 필요한 것만 허용
B=$(aws s3api list-buckets --query "Buckets[?starts_with(Name,'shop-uploads-')].Name" --output text)
cat > ~/cors.json <<'JSON'
{"CORSRules": [{
  "AllowedOrigins": ["*"],
  "AllowedMethods": ["GET", "PUT"],
  "AllowedHeaders": ["Content-Type"],
  "ExposeHeaders": ["ETag"],
  "MaxAgeSeconds": 3000
}]}
JSON
aws s3api put-bucket-cors --bucket "$B" --cors-configuration file://$HOME/cors.json
