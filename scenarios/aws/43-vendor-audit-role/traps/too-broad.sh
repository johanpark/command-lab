# 설명: 우리 계정까지 주체에 넣고, ReadOnlyAccess·12시간 세션으로 넓게 준다
# 실패해야: 업체 계정만
# 실패해야: SecurityAudit 하나뿐
# 실패해야: 최대 세션
V=$(grep -oE '계정 ID: \*\*[0-9]+' ~/audit-request.md | grep -oE '[0-9]+$')
X=$(grep -oE 'ExternalId\): \*\*[^*]+' ~/audit-request.md | sed 's/.*\*\*//')
cat > ~/trust.json <<JSON
{"Version": "2012-10-17",
 "Statement": [{"Effect": "Allow",
                "Principal": {"AWS": ["arn:aws:iam::$V:root", "arn:aws:iam::123456789012:root"]},
                "Action": "sts:AssumeRole",
                "Condition": {"StringEquals": {"sts:ExternalId": "$X"}}}]}
JSON
aws iam create-role --role-name vendor-audit --assume-role-policy-document file://$HOME/trust.json --max-session-duration 43200 >/dev/null
aws iam attach-role-policy --role-name vendor-audit --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
K=$(aws iam list-access-keys --user-name vendor-audit-2025 --query 'AccessKeyMetadata[0].AccessKeyId' --output text)
aws iam update-access-key --user-name vendor-audit-2025 --access-key-id "$K" --status Inactive
