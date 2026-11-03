# 설명: StringEqualsIfExists 는 외부 ID 를 안 보내면 통과라 의미가 없다
# 실패해야: 외부 ID
V=$(grep -oE '계정 ID: \*\*[0-9]+' ~/audit-request.md | grep -oE '[0-9]+$')
X=$(grep -oE 'ExternalId\): \*\*[^*]+' ~/audit-request.md | sed 's/.*\*\*//')
cat > ~/trust.json <<JSON
{"Version": "2012-10-17",
 "Statement": [{"Effect": "Allow",
                "Principal": {"AWS": "arn:aws:iam::$V:root"},
                "Action": "sts:AssumeRole",
                "Condition": {"StringEqualsIfExists": {"sts:ExternalId": "$X"}}}]}
JSON
aws iam create-role --role-name vendor-audit --assume-role-policy-document file://$HOME/trust.json --max-session-duration 3600 >/dev/null
aws iam attach-role-policy --role-name vendor-audit --policy-arn arn:aws:iam::aws:policy/SecurityAudit
K=$(aws iam list-access-keys --user-name vendor-audit-2025 --query 'AccessKeyMetadata[0].AccessKeyId' --output text)
aws iam update-access-key --user-name vendor-audit-2025 --access-key-id "$K" --status Inactive
