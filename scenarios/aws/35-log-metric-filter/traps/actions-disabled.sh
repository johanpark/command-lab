# 설명: 알람을 다시 저장하면서 --no-actions-enabled 로 알림을 꺼 버린다
# 모범 풀이 먼저
# 실패해야: 알림 꺼짐
T=$(aws sns list-topics --query "Topics[?ends_with(TopicArn, ':ops-alerts')].TopicArn" --output text)
aws cloudwatch put-metric-alarm --alarm-name api-errors-high --namespace Shop --metric-name ApiErrors --statistic Sum --period 60 \
  --evaluation-periods 3 --threshold 10 --comparison-operator GreaterThanOrEqualToThreshold --treat-missing-data notBreaching \
  --alarm-actions "$T" --no-actions-enabled
