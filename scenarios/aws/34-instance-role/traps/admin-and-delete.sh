# 설명: 역할에 관리자 권한을 주고, .env 의 AWS_ 줄을 다 지우고, 키를 바로 삭제한다
# 실패해야: report-bot 과 같은 권한만
# 실패해야: .env 에서 액세스 키 두 줄만
# 실패해야: 키를 비활성화
echo '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' > t.json
aws iam create-role --role-name report-server-role --assume-role-policy-document file://t.json >/dev/null
aws iam attach-role-policy --role-name report-server-role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-instance-profile --instance-profile-name report-server-profile >/dev/null
aws iam add-role-to-instance-profile --instance-profile-name report-server-profile --role-name report-server-role
I=$(aws ec2 describe-instances --filters Name=tag:Name,Values=report-server --query 'Reservations[0].Instances[0].InstanceId' --output text)
aws ec2 associate-iam-instance-profile --instance-id $I --iam-instance-profile Name=report-server-profile >/dev/null
K=$(grep -oE '^AWS_ACCESS_KEY_ID=.*' ~/report-server/.env | cut -d= -f2)
sed -i '/^AWS_/d' ~/report-server/.env
aws iam delete-access-key --user-name report-bot --access-key-id $K
