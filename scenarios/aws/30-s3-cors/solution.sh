B=$(aws s3api list-buckets --query "Buckets[?starts_with(Name,'shop-uploads-')].Name" --output text)
cat > ~/cors.json <<'JSON'
{"CORSRules": [{
  "AllowedOrigins": ["https://shop.example", "https://admin.shop.example"],
  "AllowedMethods": ["GET", "PUT"],
  "AllowedHeaders": ["Content-Type"],
  "ExposeHeaders": ["ETag"],
  "MaxAgeSeconds": 3000
}]}
JSON
aws s3api put-bucket-cors --bucket "$B" --cors-configuration file://$HOME/cors.json
