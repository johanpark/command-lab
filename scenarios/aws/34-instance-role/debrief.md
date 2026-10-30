# 해설

```bash
aws iam create-role --role-name report-server-role --assume-role-policy-document file://trust.json   # Principal: ec2.amazonaws.com
aws iam attach-role-policy --role-name report-server-role --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam put-role-policy --role-name report-server-role --policy-name put-reports --policy-document file://put-reports.json
aws iam create-instance-profile --instance-profile-name report-server-profile
aws iam add-role-to-instance-profile --instance-profile-name report-server-profile --role-name report-server-role
aws ec2 associate-iam-instance-profile --instance-id i-... --iam-instance-profile Name=report-server-profile
sed -i '/^AWS_ACCESS_KEY_ID=/d; /^AWS_SECRET_ACCESS_KEY=/d' .env
aws iam update-access-key --user-name report-bot --access-key-id AKIA... --status Inactive
```

## 키 vs 역할
| | 액세스 키 (IAM 사용자) | IAM 역할 (인스턴스 프로파일) |
|---|---|---|
| 어디에 있나 | 파일·환경 변수에 **평문** | 서버 메타데이터에서 자동으로 받음 |
| 수명 | 지울 때까지 영원히 | **몇 시간마다 자동 교체**되는 임시 자격 증명 |
| 유출되면 | 어디서든 쓸 수 있음 | 짧게 쓰고 만료 |
| 교체 | 사람이 직접 | 할 일 없음 |

서버 안에서 `aws s3 ls` 를 하면, CLI 가 자격 증명을 찾는 순서는 **환경 변수 → ~/.aws → … → 인스턴스 메타데이터(역할)** 예요. 그래서 `.env` 에서 키를 지워야 역할이 쓰여요. 키를 남겨 두면 역할을 붙여도 계속 키를 써요.

## 역할의 두 정책
- **신뢰 정책**(assume role policy): **누가** 이 역할을 맡을 수 있나 → `ec2.amazonaws.com`
- **권한 정책**: 맡은 쪽이 **무엇을** 할 수 있나 → S3 읽기 + 보고서 업로드

## 왜 키를 바로 지우지 않나
같은 키를 다른 스크립트·서버가 몰래 쓰고 있을 수 있어요. **비활성화 → 며칠 동안 에러·CloudTrail 확인 → 문제없으면 삭제** 가 안전한 순서예요. 비활성은 다시 켤 수 있지만 삭제는 되돌릴 수 없어요.

## 실무 팁
- 실제 서버에서는 IMDSv2(토큰 방식)를 강제해서(`--http-tokens required`) SSRF 공격으로 역할 자격 증명이 새는 것을 막아요.
- ECS·Lambda·EKS 도 같은 원리예요 (작업 역할, 실행 역할, IRSA). 컨테이너 이미지나 코드에 키를 넣지 마세요.
