# Parameter Store 에서 설정 파일 만들기 (SSM)

우리 팀은 설정값을 서버 파일에 적지 않고 **SSM Parameter Store** 에 경로별로 보관해요.

```
/prod/shop/db_host       (String)
/prod/shop/db_password   (SecureString  ← 암호화돼 저장)
/staging/shop/...        (검증 환경)
```

새 서버에서 앱을 띄우려면 **운영(`/prod/shop/`) 값들로 `~/app/.env`** 를 만들어야 해요.

## 목표
`~/app/.env` 를 아래 규칙으로 만드세요.
1. **`/prod/shop/` 아래의 모든 파라미터**를 한 줄에 하나씩
2. 형식은 `이름=값`. 이름은 경로의 마지막 부분을 **대문자로** (`/prod/shop/db_host` → `DB_HOST`)
3. **SecureString 도 실제 값**으로 (암호화된 그대로 쓰면 앱이 DB 에 못 붙어요)
4. 다른 환경(`/staging/...`)이나 다른 서비스 값은 넣지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ssm get-parameters-by-path --path /prod/shop` | 경로 아래 파라미터 전부 |
| `... --with-decryption` | SecureString 을 풀어서 |
| `... --query 'Parameters[].[Name,Value]' --output text` | 이름과 값만 |
| `aws ssm get-parameter --name 이름 --with-decryption` | 하나만 |
| `basename /prod/shop/db_host` | 마지막 부분 `db_host` |
| `tr a-z A-Z` | 대문자로 |
