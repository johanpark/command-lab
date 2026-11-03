# 설명: 조건을 && 로 더 붙이면 /orders 에러만 센다 (알람도 안 만듦)
# 실패해야: level 이 ERROR 인 줄만
# 실패해야: 알람이 규칙대로
aws logs put-metric-filter --log-group-name /shop/api --filter-name api-errors --filter-pattern '{ $.level = "ERROR" && $.path = "/orders" }' --metric-transformations metricName=ApiErrors,metricNamespace=Shop,metricValue=1,defaultValue=0
