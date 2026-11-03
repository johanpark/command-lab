# 설명: s3:Get*, s3:List* 처럼 읽기 계열 와일드카드로 줘도 맞는 풀이다
# 통과해야
B=$(cat ~/bucket.txt)
aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
cat > ~/policy.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:List*"     , "Resource": "arn:aws:s3:::$B" },
    { "Effect": "Allow", "Action": "s3:Get*",      "Resource": "arn:aws:s3:::$B/*" }
  ]
}
JSON
aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json
