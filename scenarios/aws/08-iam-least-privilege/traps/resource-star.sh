# 설명: Resource 를 "*" 로 쓰면 다른 버킷(finance)까지 읽을 수 있다
# 실패해야: 다른 버킷(finance)은 못 본다
B=$(cat ~/bucket.txt)
aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
cat > ~/policy.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListBucket", "Resource": "*" },
    { "Effect": "Allow", "Action": "s3:GetObject",  "Resource": "*" }
  ]
}
JSON
aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json
