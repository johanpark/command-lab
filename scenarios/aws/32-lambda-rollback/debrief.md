# 해설

```bash
aws lambda update-alias --function-name order-api --name live --function-version 2          # 즉시 롤백
aws lambda get-function-configuration --function-name order-api --query Environment --output json \
  | jq '.Variables.DB_HOST = "db-2.internal"' > env.json                                       # 하나만 바꾸기
aws lambda update-function-configuration --function-name order-api --environment file://env.json
V=$(aws lambda publish-version --function-name order-api --description "DB_HOST 오타 수정" --query Version --output text)
aws lambda update-alias --function-name order-api --name staging --function-version $V
aws lambda put-function-concurrency --function-name order-api --reserved-concurrent-executions 100
```

## 버전과 별칭
```
$LATEST (고칠 수 있는 작업본) ──publish──▶ 버전 1, 2, 3, 4 (고정, 못 고침)
별칭 live    ──▶ 2   ← API Gateway·이벤트는 별칭을 호출
별칭 staging ──▶ 4
```
- 버전은 코드 + 설정(환경 변수, 타임아웃…)을 **한 번에 얼려 둔 것**이라, 별칭만 옮기면 코드·설정이 통째로 예전 상태가 돼요.
- 그래서 트리거(API Gateway, SQS 등)는 함수 이름이 아니라 **별칭 ARN**(`...:function:order-api:live`)에 연결해 두는 게 정석이에요.

## 환경 변수 덮어쓰기 함정
`--environment "Variables={DB_HOST=db-2.internal}"` 처럼 하나만 넣으면 `LOG_LEVEL`, `PG_API_URL`, `FEATURE_COUPON` 이 **모두 지워진** 새 설정이 돼요. 다음 배포 때 또 다른 장애가 나는 흔한 원인이에요. 항상 "받아서 → 고쳐서 → 통째로 넣기".

## 예약 동시 실행
- 람다는 요청이 몰리면 수백 개가 동시에 떠요. 각각 DB 연결을 열면 **DB 가 먼저 죽어요.** 예약 동시 실행은 "이 함수는 최대 N 개까지만" 이라는 상한이에요.
- 0 으로 설정하면 함수가 **아예 호출되지 않아요** (긴급 차단 스위치).

## 실무 팁
- 별칭에 **가중치 라우팅**(`--routing-config AdditionalVersionWeights={"4"=0.1}`)을 걸면 새 버전에 10% 만 보내는 카나리 배포를 할 수 있어요. CodeDeploy 와 함께 쓰면 에러가 늘면 자동으로 되돌려요.
- 비밀번호 같은 값은 환경 변수 대신 Secrets Manager / Parameter Store 에서 읽으세요.
