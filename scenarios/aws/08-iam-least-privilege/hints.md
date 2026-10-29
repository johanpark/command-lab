먼저 떼기: `aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess`. 혹시 다른 인라인 정책도 있는지 `aws iam list-user-policies --user-name report-bot` 으로 확인하세요.
---
S3 권한의 함정: **ListBucket 은 버킷**에, **GetObject 는 버킷 안의 파일들**에 거는 권한이라 Resource 가 달라요.
- 버킷: `arn:aws:s3:::버킷이름`
- 버킷 안 파일들: `arn:aws:s3:::버킷이름/*`
---
`nano ~/policy.json` 으로 만들기 (버킷 이름은 `cat ~/bucket.txt`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListBucket", "Resource": "arn:aws:s3:::버킷이름" },
    { "Effect": "Allow", "Action": "s3:GetObject",  "Resource": "arn:aws:s3:::버킷이름/*" }
  ]
}
```
---
붙이기: `aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json`. `"Action": "s3:*"` 나 `"Resource": "*"` 처럼 넓게 쓰면 쓰기·삭제나 다른 버킷까지 열려요.
