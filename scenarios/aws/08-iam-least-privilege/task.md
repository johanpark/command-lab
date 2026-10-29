# 관리자 권한을 가진 봇 계정 줄이기 (IAM 최소 권한)

매일 아침 보고서 파일을 읽어 가는 봇 계정 **`report-bot`** 이 있어요. 그런데 권한 점검을 해 보니...

```
$ aws iam list-attached-user-policies --user-name report-bot
AdministratorAccess          ← 모든 AWS 자원을 마음대로!
```

이 봇의 접속 키가 새면 계정 전체가 털려요. 봇이 실제로 하는 일은 **보고서 버킷(`reports-...`)의 파일 목록을 보고 파일을 읽는 것**뿐이에요.

## 목표 (`report-bot` 사용자)
1. **`AdministratorAccess` 를 떼세요.**
2. 다음 **두 가지만** 허용하는 정책을 붙이세요. (인라인 정책이든 관리형 정책이든 OK)
   - 보고서 버킷의 **파일 목록 보기** (`s3:ListBucket`)
   - 보고서 버킷의 **파일 읽기** (`s3:GetObject`)
3. 쓰기·삭제, 다른 버킷, 다른 서비스는 **아무것도** 못 하게.

보고서 버킷 이름은 `~/bucket.txt` 에 있어요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws iam list-attached-user-policies --user-name 이름` | 붙은 관리형 정책 |
| `aws iam list-user-policies --user-name 이름` | 인라인 정책 이름 |
| `aws iam detach-user-policy --user-name 이름 --policy-arn arn:aws:iam::aws:policy/AdministratorAccess` | 정책 떼기 |
| `aws iam put-user-policy --user-name 이름 --policy-name 정책이름 --policy-document file://파일.json` | 인라인 정책 붙이기 |
| `aws iam get-user-policy --user-name 이름 --policy-name 정책이름` | 확인 |

정책 문서 모양:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "행동", "Resource": "arn:aws:s3:::..." }
  ]
}
```
