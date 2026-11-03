# 설명: 읽기를 Allow 하고 같은 범위를 Deny 하면 명시적 거부가 이겨서 실제로는 못 읽는다
# 실패해야: 보고서 버킷의 파일을 읽을 수 있다
B=$(cat ~/bucket.txt)
aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
cat > ~/policy.json <<JSON
{"Version": "2012-10-17",
 "Statement": [
  {"Effect": "Allow", "Action": "s3:ListBucket", "Resource": "arn:aws:s3:::$B"},
  {"Effect": "Allow", "Action": "s3:GetObject", "Resource": "arn:aws:s3:::$B/*"},
  {"Effect": "Deny", "Action": "s3:GetObject", "Resource": "arn:aws:s3:::$B/2026/*"}]}
JSON
aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json
