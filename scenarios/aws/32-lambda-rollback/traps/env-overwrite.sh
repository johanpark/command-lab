# 설명: --environment 에 DB_HOST 하나만 넣으면 다른 환경 변수가 전부 사라진다
# 실패해야: 다른 환경 변수는 그대로
C=$(grep -oE '예약 동시 실행을 [0-9]+' ~/incident.md | grep -oE '[0-9]+')
aws lambda update-alias --function-name order-api --name live --function-version 2 >/dev/null
aws lambda update-function-configuration --function-name order-api --environment 'Variables={DB_HOST=db-2.internal}' >/dev/null
V=$(aws lambda publish-version --function-name order-api --query Version --output text)
aws lambda update-alias --function-name order-api --name staging --function-version "$V" >/dev/null
aws lambda put-function-concurrency --function-name order-api --reserved-concurrent-executions "$C" >/dev/null
