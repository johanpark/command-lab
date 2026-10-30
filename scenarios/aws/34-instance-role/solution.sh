B=$(grep -oE '^REPORT_BUCKET=.*' ~/report-server/.env | cut -d= -f2)
cat > ~/trust.json <<'JSON'
{"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Principal": {"Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}]}
JSON
aws iam create-role --role-name report-server-role --assume-role-policy-document file://$HOME/trust.json >/dev/null
aws iam attach-role-policy --role-name report-server-role --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam put-role-policy --role-name report-server-role --policy-name put-reports \
  --policy-document "$(aws iam get-user-policy --user-name report-bot --policy-name put-reports --query PolicyDocument --output json)"
aws iam create-instance-profile --instance-profile-name report-server-profile >/dev/null
aws iam add-role-to-instance-profile --instance-profile-name report-server-profile --role-name report-server-role
I=$(aws ec2 describe-instances --filters Name=tag:Name,Values=report-server --query 'Reservations[0].Instances[0].InstanceId' --output text)
aws ec2 associate-iam-instance-profile --instance-id "$I" --iam-instance-profile Name=report-server-profile >/dev/null
K=$(grep -oE '^AWS_ACCESS_KEY_ID=.*' ~/report-server/.env | cut -d= -f2)
sed -i '/^AWS_ACCESS_KEY_ID=/d; /^AWS_SECRET_ACCESS_KEY=/d' ~/report-server/.env
aws iam update-access-key --user-name report-bot --access-key-id "$K" --status Inactive
