규칙 하나에 경로(Prefix) 하나예요. `logs/` 용 규칙과 `tmp/` 용 규칙, **두 개**를 `"Rules"` 목록에 넣으면 돼요. `backups/` 는 규칙을 안 만들면 그대로 남아요.
---
⚠️ `"Filter": { "Prefix": "" }` 처럼 경로를 비우면 **버킷 전체**에 적용돼서 백업까지 지워져요!
---
`nano ~/lifecycle.json`:
```json
{
  "Rules": [
    { "ID": "logs", "Status": "Enabled", "Filter": { "Prefix": "logs/" },
      "Transitions": [ { "Days": 30, "StorageClass": "GLACIER" } ],
      "Expiration": { "Days": 365 } },
    { "ID": "tmp", "Status": "Enabled", "Filter": { "Prefix": "tmp/" },
      "Expiration": { "Days": 7 } }
  ]
}
```
---
`aws s3api put-bucket-lifecycle-configuration --bucket $(cat ~/bucket.txt) --lifecycle-configuration file://$HOME/lifecycle.json` → `aws s3api get-bucket-lifecycle-configuration --bucket $(cat ~/bucket.txt)` 로 확인!
