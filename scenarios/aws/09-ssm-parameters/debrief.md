# 해설

```bash
aws ssm get-parameters-by-path --path /prod/shop --with-decryption \
  --query 'Parameters[].[Name,Value]' --output text |
while read -r name value; do
  echo "$(basename "$name" | tr a-z A-Z)=$value"
done > ~/app/.env
chmod 600 ~/app/.env
```

## String vs SecureString
| 타입 | 저장 | 꺼낼 때 |
|---|---|---|
| `String` | 그대로 | 그대로 |
| `SecureString` | **KMS 키로 암호화** | `--with-decryption` + KMS 복호화 권한이 있어야 실제 값 |

권한 설계가 쉬워져요. 설정값(`ssm:GetParameter`)은 넓게, 비밀번호 복호화(`kms:Decrypt`)는 앱 서버 역할에만.

## 경로로 정리하는 습관
```
/prod/shop/...     /staging/shop/...     /prod/batch/...
```
`get-parameters-by-path --path /prod/shop` 한 번으로 그 앱의 운영 설정을 다 받을 수 있고, IAM 정책도 `arn:aws:ssm:...:parameter/prod/shop/*` 처럼 경로로 줄 수 있어요. 하위 경로까지 받으려면 `--recursive`.

## 파일로 안 만들고 쓰는 방법
`.env` 파일도 결국 디스크에 남아요. 더 좋은 건
- 앱이 시작할 때 SDK 로 직접 읽기
- ECS 작업 정의의 `secrets` / Lambda 환경 변수에 SSM 참조 넣기
- systemd 의 `EnvironmentFile` 대신 시작 스크립트에서 메모리로만 export

Secrets Manager(시나리오 06) 와 비교하면, Parameter Store 는 **설정값 + 간단한 비밀**에, Secrets Manager 는 **자동 교체가 필요한 비밀**에 많이 써요.
