# 설명: JSON 패턴 대신 "\"level\": \"ERROR\"" 처럼 따옴표째 글자로 찾아도 level 이 ERROR 인 줄만 걸린다
# 통과해야
aws logs put-metric-filter --log-group-name /shop/api --filter-name api-errors --filter-pattern '"\"level\": \"ERROR\""' --metric-transformations metricName=ApiErrors,metricNamespace=Shop,metricValue=1,defaultValue=0
T=$(aws sns list-topics --query "Topics[?ends_with(TopicArn, ':ops-alerts')].TopicArn" --output text)
aws cloudwatch put-metric-alarm --alarm-name api-errors-high --namespace Shop --metric-name ApiErrors \
  --statistic Sum --period 60 --evaluation-periods 3 --threshold 10 \
  --comparison-operator GreaterThanOrEqualToThreshold --treat-missing-data notBreaching --alarm-actions "$T"
