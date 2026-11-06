# 설명: logs 규칙의 접두사를 비우면 버킷 전체(backup/ 포함)가 1년 뒤 지워진다
# 실패해야: backup
cat > ~/lifecycle.json <<'JSON'
{
  "Rules": [
    { "ID": "logs", "Status": "Enabled", "Filter": { "Prefix": "" },
      "Transitions": [ { "Days": 30, "StorageClass": "GLACIER" } ],
      "Expiration": { "Days": 365 } },
    { "ID": "tmp", "Status": "Enabled", "Filter": { "Prefix": "tmp/" },
      "Expiration": { "Days": 7 } }
  ]
}
JSON
aws s3api put-bucket-lifecycle-configuration --bucket "$(cat ~/bucket.txt)" --lifecycle-configuration file://$HOME/lifecycle.json
