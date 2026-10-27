# 앱이 환경 변수를 못 읽어요

`~/app/run.sh` 는 **환경 변수**로 설정을 받는 앱이에요. 그런데 분명히 값을 설정했는데 앱이 못 읽는대요.

```
$ APP_ENV=production
$ echo $APP_ENV
production
$ ~/app/run.sh
❌ APP_ENV 가 설정되지 않았습니다
```

## 목표
`~/app/run.sh` 를 실행해서 **앱 시작에 성공**하세요. (성공하면 `~/app/started.txt` 가 생겨요)
- `APP_ENV` 는 `production`, `LOG_LEVEL` 은 `warn` 으로
- DB 설정(`DB_HOST`, `DB_USER`, `DB_PASSWORD`)은 `~/app/.env` 에 있어요. 이 값들을 **불러와서** 쓰세요.
- `run.sh` 와 `.env` 파일은 **수정하지 마세요.** (값을 스크립트에 직접 적는 건 반칙!)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `VAR=값` | 셸 변수 (이 셸 안에서만 보임) |
| `export VAR=값` | 환경 변수 (이 셸이 실행하는 **프로그램에도** 전달) |
| `VAR=값 명령` | 그 명령 한 번에만 전달 |
| `env` / `printenv VAR` | 지금 환경 변수 목록 / 값 |
| `source 파일` | 파일 안의 명령을 지금 셸에서 실행 |
| `set -a` / `set +a` | 그 사이에 만든 변수를 자동으로 export / 끄기 |
