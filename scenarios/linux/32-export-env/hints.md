`APP_ENV=production` 다음에 `env | grep APP_ENV` 를 쳐 보세요. 아무것도 안 나오죠? 셸 변수는 **자식 프로그램(run.sh)에 전달되지 않아요.** `export APP_ENV=production` 을 하면 달라져요.
---
한 번만 넘기고 싶다면: `APP_ENV=production LOG_LEVEL=warn ~/app/run.sh`. 이번엔 DB 설정이 없다고 할 거예요.
---
`cat ~/app/.env` 를 보면 `DB_HOST=...` 처럼 `export` 없이 적혀 있어요. 그냥 `source ~/app/.env` 하면 셸 변수만 생겨서 run.sh 는 못 봐요.
---
`set -a` 를 켜고 source 하면 전부 export 돼요: `set -a; source ~/app/.env; set +a` → `export APP_ENV=production LOG_LEVEL=warn` → `~/app/run.sh`
