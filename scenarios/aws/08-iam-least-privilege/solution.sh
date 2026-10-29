B=$(cat ~/bucket.txt)
aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
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
