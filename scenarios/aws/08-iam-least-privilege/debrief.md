# 해설

```bash
B=$(cat ~/bucket.txt)
aws iam detach-user-policy --user-name report-bot --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
cat > ~/policy.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListBucket", "Resource": "arn:aws:s3:::$B" },
    { "Effect": "Allow", "Action": "s3:GetObject",  "Resource": "arn:aws:s3:::$B/*" }
  ]
}
JSON
aws iam put-user-policy --user-name report-bot --policy-name read-reports --policy-document file://$HOME/policy.json
```

## 최소 권한 (Least Privilege)
"일하는 데 **필요한 만큼만**" 주는 원칙이에요. 키가 새거나 봇에 버그가 있어도 피해가 그 범위를 넘지 않아요.

| 너무 넓은 예 | 왜 위험한가 |
|---|---|
| `AdministratorAccess` | 계정 전체 (사용자 생성, 서버 삭제, 요금 폭탄) |
| `"Action": "s3:*"` | 읽기만 하면 되는데 삭제까지 |
| `"Resource": "*"` | 다른 팀 버킷까지 (개인정보 버킷이 있다면?) |

## S3 리소스 ARN 함정
| 행동 | 대상 | Resource |
|---|---|---|
| `s3:ListBucket` | 버킷 | `arn:aws:s3:::버킷` |
| `s3:GetObject`, `s3:PutObject` | 파일(객체) | `arn:aws:s3:::버킷/*` |

`GetObject` 를 버킷 ARN 에만 걸면 "권한을 줬는데 AccessDenied" 가 나요. 가장 흔한 IAM 실수 중 하나예요.

## 더 나아가기
- 사람·봇에 **장기 접속 키** 대신 **IAM 역할**(EC2 인스턴스 프로필, Lambda 실행 역할)을 쓰면 키 유출 걱정이 줄어요.
- 무엇이 필요한지 모를 땐 **IAM Access Analyzer** 가 실제 사용 기록(CloudTrail)을 보고 정책을 만들어 줘요.
- 확인은 `aws iam simulate-principal-policy --policy-source-arn ... --action-names s3:PutObject` 로.
- 진짜 AWS 에서는 바꾼 뒤 봇이 정상 동작하는지 꼭 시험하세요. (이 실습의 가짜 AWS 는 권한을 실제로 막지는 않아요)
