# 해설

```bash
set -a                    # 이제부터 만드는 변수는 자동 export
source ~/app/.env
set +a
export APP_ENV=production LOG_LEVEL=warn
~/app/run.sh
```
또는 한 줄로:
```bash
env $(grep -v '^#' ~/app/.env | xargs) APP_ENV=production LOG_LEVEL=warn ~/app/run.sh
```

## 셸 변수 vs 환경 변수
```
내 셸 ── VAR=x          (셸 변수: 나만 앎)
  │      export VAR=x   (환경 변수: 자식에게 물려줌)
  └─▶ run.sh            ← 환경 변수만 받음
```
- `echo $VAR` 는 둘 다 보여줘서 헷갈려요. **프로그램이 받는지** 확인하려면 `env | grep VAR` 또는 `printenv VAR`.
- 자식이 바꾼 값은 부모에게 돌아오지 않아요. 그래서 스크립트를 `./x.sh` 로 실행하면 그 안의 `cd`, `export` 가 내 셸에 반영되지 않고, `source x.sh` 로 실행해야 반영돼요.

## .env 파일 다루기
| 방법 | 특징 |
|---|---|
| `set -a; source .env; set +a` | 간단. 값에 공백·특수문자가 있으면 따옴표 필요 |
| `docker run --env-file .env` | Docker 가 직접 읽음 |
| 앱의 dotenv 라이브러리 | 앱이 직접 읽음 (Node, Python 등) |

⚠️ `.env` 에는 비밀번호가 있으니 Git 에 올리지 마세요 (`.gitignore`). 이 시나리오의 앱도 비밀번호 대신 해시만 기록해요.
