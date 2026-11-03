# 설명: 신뢰 정책을 lambda 로 쓰고, 권한·프로파일·연결을 빼먹고 키만 끈다
# 실패해야: EC2 가 맡을 수 있다
# 실패해야: report-bot 과 같은 권한이 있다
# 실패해야: report-server-profile 에 역할이
# 실패해야: 프로파일이 연결돼
# 실패해야: .env 에서 액세스 키를
echo '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' > t.json
aws iam create-role --role-name report-server-role --assume-role-policy-document file://t.json >/dev/null
aws iam attach-role-policy --role-name report-server-role --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
K=$(grep -oE '^AWS_ACCESS_KEY_ID=.*' ~/report-server/.env | cut -d= -f2)
aws iam update-access-key --user-name report-bot --access-key-id $K --status Inactive
