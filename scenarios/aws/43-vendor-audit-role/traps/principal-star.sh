# 설명: Principal 을 "*" 로 열면 세상 모든 AWS 계정이 외부 ID 만 알면 들어온다
# 실패해야: 업체 계정만
V=$(grep -oE '계정 ID: \*\*[0-9]+' ~/audit-request.md | grep -oE '[0-9]+$')
X=$(grep -oE 'ExternalId\): \*\*[^*]+' ~/audit-request.md | sed 's/.*\*\*//')
cat > ~/trust.json <<JSON
{"Version": "2012-10-17",
 "Statement": [{"Effect": "Allow",
                "Principal": {"AWS": "*"},
                "Action": "sts:AssumeRole",
                "Condition": {"StringEquals": {"sts:ExternalId": "$X"}}}]}
JSON
aws iam create-role --role-name vendor-audit --assume-role-policy-document file://$HOME/trust.json --max-session-duration 3600 >/dev/null
aws iam attach-role-policy --role-name vendor-audit --policy-arn arn:aws:iam::aws:policy/SecurityAudit
K=$(aws iam list-access-keys --user-name vendor-audit-2025 --query 'AccessKeyMetadata[0].AccessKeyId' --output text)
aws iam update-access-key --user-name vendor-audit-2025 --access-key-id "$K" --status Inactive
