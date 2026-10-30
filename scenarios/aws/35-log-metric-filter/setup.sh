#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
aws sns create-topic --name ops-alerts --query TopicArn --output text > $S/topic
aws logs create-log-group --log-group-name /shop/api
aws logs create-log-group --log-group-name /shop/batch
python3 - > $S/events.json <<'PY'
import json, random, time
now = int(time.time() * 1000) - 3600_000
paths = ['/orders', '/cart', '/login', '/products', '/coupons']
lines = []
for k in range(160):
    r = random.random()
    p = random.choice(paths)
    if r < 0.18:
        lines.append({'level': 'ERROR', 'path': p, 'msg': random.choice(['DB timeout', 'PG 응답 없음', 'NullPointer in OrderService', 'Redis connection refused'])})
    elif r < 0.30:
        lines.append({'level': 'INFO', 'path': p, 'msg': random.choice(['retry succeeded after ERROR_TIMEOUT', 'user typed "ERROR" in search', 'ERROR page rendered (404 for missing product)'])})
    elif r < 0.40:
        lines.append({'level': 'WARN', 'path': p, 'msg': 'slow query, error budget 80% used'})
    else:
        lines.append({'level': 'INFO', 'path': p, 'msg': 'ok', 'ms': random.randint(5, 300)})
ev = [{'timestamp': now + i * 20_000, 'message': json.dumps(l, ensure_ascii=False)} for i, l in enumerate(lines)]
print(json.dumps(ev, ensure_ascii=False))
PY
aws logs create-log-stream --log-group-name /shop/api --log-stream-name api-1
AWS_DISABLE_REQUEST_COMPRESSION=true aws logs put-log-events --log-group-name /shop/api --log-stream-name api-1 --log-events file://$S/events.json >/dev/null
jq '[.[] | .message | fromjson | select(.level == "ERROR")] | length' $S/events.json > $S/errors
mkdir -p "$H"
cat > "$H/alert-rule.md" <<'MD'
# API 에러 알람 규칙

로그 그룹: /shop/api (한 줄에 JSON 하나: {"level": "...", "path": "...", "msg": "..."})

1. 지표 필터 `api-errors`
   - **level 이 ERROR 인 줄만** 센다 (msg 에 ERROR 라는 글자가 있는 INFO 줄은 에러가 아님!)
   - 지표: 네임스페이스 **Shop**, 이름 **ApiErrors**, 한 줄에 **1**, 에러가 없을 땐 **0**
2. 알람 `api-errors-high`
   - ApiErrors 의 **합계(Sum)** 가 **1분**에 **10 이상**인 상태가 **3분 연속**이면
   - SNS 토픽 **ops-alerts** 로 알림
   - 데이터가 없을 때는 정상으로 본다 (notBreaching)
MD
give "$H/alert-rule.md"
