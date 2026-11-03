# 설명: 패턴을 ERROR 글자로만 걸면 msg 에 ERROR 가 든 INFO 줄까지 센다 (기본값·비교·데이터 없음 처리도 빠짐)
# 실패해야: level 이 ERROR 인 줄만
# 실패해야: 기본값 0
# 실패해야: 알람이 규칙대로
aws logs put-metric-filter --log-group-name /shop/api --filter-name api-errors --filter-pattern 'ERROR' --metric-transformations metricName=ApiErrors,metricNamespace=Shop,metricValue=1
T=$(aws sns list-topics --query "Topics[0].TopicArn" --output text)
aws cloudwatch put-metric-alarm --alarm-name api-errors-high --namespace Shop --metric-name ApiErrors --statistic Sum --period 60 --evaluation-periods 3 --threshold 10 --comparison-operator GreaterThanThreshold --alarm-actions $T
