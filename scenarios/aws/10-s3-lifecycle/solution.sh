cat > ~/lifecycle.json <<'JSON'
{
  "Rules": [
    { "ID": "logs", "Status": "Enabled", "Filter": { "Prefix": "logs/" },
      "Transitions": [ { "Days": 30, "StorageClass": "GLACIER" } ],
      "Expiration": { "Days": 365 } },
    { "ID": "tmp", "Status": "Enabled", "Filter": { "Prefix": "tmp/" },
      "Expiration": { "Days": 7 } }
  ]
}
JSON
aws s3api put-bucket-lifecycle-configuration --bucket "$(cat ~/bucket.txt)" --lifecycle-configuration file://$HOME/lifecycle.json
