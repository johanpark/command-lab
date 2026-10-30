버전별로 무엇이 달랐는지: `aws lambda list-versions-by-function --function-name order-api --query "Versions[].[Version,Description,Environment.Variables.DB_HOST]" --output table`
장애 버전은 3, 그 **직전**에 정상이던 버전은? (1 은 옛 DB 를 써요)
`aws lambda update-alias --function-name order-api --name live --function-version <정상 버전>`
---
환경 변수를 하나만 바꾸는 안전한 방법: 지금 설정을 받아서 jq 로 그 값만 바꾼 뒤 통째로 넣기
```
aws lambda get-function-configuration --function-name order-api --query Environment --output json \
  | jq '.Variables.DB_HOST = "db-2.internal"' > env.json
aws lambda update-function-configuration --function-name order-api --environment file://env.json
```
---
`aws lambda publish-version --function-name order-api --description "DB_HOST 오타 수정"` → 출력의 `Version` 번호를
`aws lambda update-alias --function-name order-api --name staging --function-version <그 번호>` 에.
(live 는 그대로 2!)
---
`aws lambda put-function-concurrency --function-name order-api --reserved-concurrent-executions <메모의 값>`
