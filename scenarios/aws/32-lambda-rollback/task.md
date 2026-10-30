# 배포 직후 에러 폭발, 람다 되돌리기 (Lambda 버전·별칭)

10분 전에 배포한 주문 API 람다 **`order-api`** 가 에러를 쏟아내고 있어요. 장애 메모는 `~/incident.md` 에 있어요.

람다는 배포할 때마다 **버전**(1, 2, 3 …)을 발행하고, 실제 트래픽은 **별칭**(`live`, `staging`)이 가리키는 버전으로 가요.
그래서 별칭만 옮기면 코드 재배포 없이 몇 초 만에 되돌릴 수 있어요.

## 목표
1. `live` 별칭을 **장애 직전의 정상 버전**으로 되돌리세요.
2. `$LATEST` 의 `DB_HOST` 를 `db-2.internal` 로 고치세요. **다른 환경 변수는 그대로** 둬야 해요.
3. 고친 설정으로 **새 버전을 발행**하고, **`staging` 별칭만** 그 버전으로 옮기세요.
4. 함수의 **예약 동시 실행(reserved concurrency)** 을 메모에 적힌 값으로 제한하세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws lambda list-versions-by-function --function-name order-api --query "Versions[].[Version,Description,Environment.Variables.DB_HOST]" --output table` | 버전별 설정 |
| `aws lambda list-aliases --function-name order-api` | 별칭이 가리키는 버전 |
| `aws lambda update-alias --function-name order-api --name 별칭 --function-version 버전` | 별칭 옮기기 |
| `aws lambda get-function-configuration --function-name order-api` | `$LATEST` 설정 |
| `aws lambda update-function-configuration --function-name order-api --environment file://env.json` | 설정 바꾸기 |
| `aws lambda publish-version --function-name order-api --description "설명"` | 지금 `$LATEST` 를 새 버전으로 고정 |
| `aws lambda put-function-concurrency --function-name order-api --reserved-concurrent-executions N` | 동시 실행 한도 |

> ⚠️ `--environment` 는 환경 변수 **전체를 교체**해요. 하나만 바꾸고 싶어도 나머지를 모두 함께 넣어야 해요.
