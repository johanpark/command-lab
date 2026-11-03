# 설명: s3:* 로 주면 보고서 버킷에 쓰고 지울 수도 있다
# 실패해야: 쓰기·삭제는 못 한다
B=$(cat ~/bucket.txt)
aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
cat > ~/policy.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListBucket", "Resource": "arn:aws:s3:::$B" },
    { "Effect": "Allow", "Action": "s3:*",        "Resource": "arn:aws:s3:::$B/*" }
  ]
}
JSON
aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json
