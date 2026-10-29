# .env 의 비밀번호를 Secrets Manager 로 옮기기

보안 점검에서 또 지적을 받았어요.

> 운영 서버의 `~/app/.env` 에 **DB 비밀번호가 평문**으로 있습니다. 서버에 접속할 수 있는 누구나, 백업 파일을 받은 누구나 볼 수 있어요.

AWS 의 **Secrets Manager** 에 비밀번호를 보관하고, 앱이 시작할 때 꺼내 쓰게 바꿉시다.

## 목표
1. Secrets Manager 에 **`prod/shop/db`** 라는 비밀을 만드세요. 값은 **JSON** 으로:
   ```json
   {"username": "shop", "password": "지금 .env 에 있는 비밀번호"}
   ```
2. `~/app/.env` 에서 **`DB_PASSWORD` 줄을 지우세요.** (다른 설정은 그대로)
3. `~/app/start.sh` 가 **Secrets Manager 에서 비밀번호를 가져오도록** 고치세요.
4. `~/app/start.sh` 를 실행해서 **DB 연결 성공**이 나와야 해요.

`~/app` 폴더 어디에도 비밀번호가 글자로 남아 있으면 안 돼요. (스크립트에 직접 적는 것도 반칙!)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws secretsmanager create-secret --name 이름 --secret-string '{"k":"v"}'` | 비밀 만들기 |
| `aws secretsmanager get-secret-value --secret-id 이름` | 비밀 꺼내기 |
| `... --query SecretString --output text` | 값(JSON 문자열)만 |
| `jq -r .password` | JSON 에서 password 만 |
| `sed -i '/^DB_PASSWORD=/d' 파일` | 그 줄 지우기 |
