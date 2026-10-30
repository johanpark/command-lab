버킷과 리전 확인: `aws s3 ls` → `aws s3api get-bucket-location --bucket <이름>` (복제본은 us-west-2)
버전 관리부터 둘 다: `aws s3api put-bucket-versioning --bucket <버킷> --versioning-configuration Status=Enabled`
(안 켜고 복제를 걸면 `Versioning must be 'Enabled'` 에러)
---
역할은 두 개가 보일 텐데, **S3 가 맡을 수 있는** 역할이어야 해요:
`aws iam get-role --role-name s3-replication-role --query "Role.[Arn,AssumeRolePolicyDocument.Statement[0].Principal]"`
---
`repl.json`:
```json
{"Role": "arn:aws:iam::123456789012:role/s3-replication-role",
 "Rules": [{"ID": "orders-to-dr", "Status": "Enabled", "Priority": 1,
            "Filter": {"Prefix": "orders/"},
            "DeleteMarkerReplication": {"Status": "Disabled"},
            "Destination": {"Bucket": "arn:aws:s3:::<복제본 버킷>", "StorageClass": "STANDARD_IA"}}]}
```
`aws s3api put-bucket-replication --bucket <원본> --replication-configuration file://repl.json`
