# 설명: 새 정책만 붙이고 AdministratorAccess 를 그대로 두면 소용없다
# 실패해야: AdministratorAccess 를 뗐다
# 실패해야: 다른 서비스
B=$(cat ~/bucket.txt)
cat > ~/policy.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListBucket", "Resource": "arn:aws:s3:::$B" },
    { "Effect": "Allow", "Action": "s3:GetObject",  "Resource": "arn:aws:s3:::$B/*" }
  ]
}
JSON
aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json
