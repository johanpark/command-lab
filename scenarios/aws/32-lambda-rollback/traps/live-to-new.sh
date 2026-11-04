# 설명: 고친 새 버전을 QA 없이 바로 live 에 연결한다
# 실패해야: live 가 장애 직전 정상 버전
C=$(grep -oE '예약 동시 실행을 [0-9]+' ~/incident.md | grep -oE '[0-9]+')
aws lambda get-function-configuration --function-name order-api --query Environment --output json | jq '.Variables.DB_HOST = "db-2.internal"' > ~/env.json
aws lambda update-function-configuration --function-name order-api --environment file://$HOME/env.json >/dev/null
V=$(aws lambda publish-version --function-name order-api --query Version --output text)
aws lambda update-alias --function-name order-api --name live --function-version "$V" >/dev/null
aws lambda update-alias --function-name order-api --name staging --function-version "$V" >/dev/null
aws lambda put-function-concurrency --function-name order-api --reserved-concurrent-executions "$C" >/dev/null
