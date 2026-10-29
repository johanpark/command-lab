`cat ~/app/.env` 와 `cat ~/app/start.sh` 를 먼저 보세요. start.sh 는 `.env` 를 읽고 `DB_PASSWORD` 로 접속해요.
---
비밀 만들기 (비밀번호를 손으로 옮겨 적지 말고 파일에서 꺼내서):
```
pw=$(grep '^DB_PASSWORD=' ~/app/.env | cut -d= -f2-)
aws secretsmanager create-secret --name prod/shop/db \
  --secret-string "$(jq -n --arg p "$pw" '{username: "shop", password: $p}')"
```
`jq -n` 으로 만들면 비밀번호에 따옴표 같은 특수문자가 있어도 JSON 이 깨지지 않아요.
---
꺼내 보기: `aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text | jq -r .password`. 이 한 줄을 start.sh 에서 쓰면 돼요.
---
start.sh 의 `source ./.env` 바로 다음 줄에:
```
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text | jq -r .password)
```
그리고 `sed -i '/^DB_PASSWORD=/d' ~/app/.env` → `~/app/start.sh` 실행!
