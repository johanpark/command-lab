# DB 포트를 앱 서버에서만 열기 (보안 그룹 참조)

보안 점검에서 **DB(5432)와 캐시(6379) 포트가 너무 넓게 열려 있다**는 지적을 받았어요. 결과는 `~/security-review.md` 에 있어요.

서버 IP 는 오토스케일링으로 계속 바뀌어서 IP 로 허용하기 어려워요. 대신 **"app-sg 가 붙은 서버에서 오는 것만 허용"** 처럼 **보안 그룹을 출처로** 지정할 수 있어요.

## 목표
1. `db-sg` 의 5432 를 **`app-sg` 와 `bastion-sg` 에서만** 들어올 수 있게 하세요. (IP 대역 규칙은 모두 없애기)
2. `cache-sg` 의 6379 를 **`app-sg` 에서만** 들어올 수 있게 하세요.
3. `alb-sg`, `app-sg`, `bastion-sg` 는 그대로 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-security-groups --filters Name=group-name,Values=db-sg` | 보안 그룹 정보 |
| `aws ec2 describe-security-group-rules --filters Name=group-id,Values=sg-...` | 규칙 하나하나와 규칙 ID |
| `aws ec2 revoke-security-group-ingress --group-id sg-... --security-group-rule-ids sgr-...` | 규칙 지우기 |
| `aws ec2 authorize-security-group-ingress --group-id sg-... --protocol tcp --port 5432 --source-group sg-...` | 다른 보안 그룹을 출처로 허용 |
