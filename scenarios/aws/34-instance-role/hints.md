report-bot 의 권한부터:
```
aws iam list-attached-user-policies --user-name report-bot
aws iam list-user-policies --user-name report-bot
aws iam get-user-policy --user-name report-bot --policy-name put-reports
```
---
신뢰 정책 `trust.json` ("누가 이 역할을 맡을 수 있나"):
```json
{"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Principal": {"Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}]}
```
`aws iam create-role --role-name report-server-role --assume-role-policy-document file://trust.json`
---
권한은 report-bot 과 똑같이:
- 관리형: `aws iam attach-role-policy --role-name report-server-role --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess`
- 인라인: `get-user-policy` 로 본 문서를 그대로 `aws iam put-role-policy --role-name report-server-role --policy-name put-reports --policy-document '...'`
---
EC2 에는 역할을 직접 못 붙이고 **인스턴스 프로파일**이라는 상자에 넣어서 붙여요:
```
aws iam create-instance-profile --instance-profile-name report-server-profile
aws iam add-role-to-instance-profile --instance-profile-name report-server-profile --role-name report-server-role
aws ec2 associate-iam-instance-profile --instance-id i-... --iam-instance-profile Name=report-server-profile
```
---
`.env` 에서 두 줄만: `sed -i '/^AWS_ACCESS_KEY_ID=/d; /^AWS_SECRET_ACCESS_KEY=/d' ~/report-server/.env`
키 비활성화: `aws iam update-access-key --user-name report-bot --access-key-id <키 ID> --status Inactive`
