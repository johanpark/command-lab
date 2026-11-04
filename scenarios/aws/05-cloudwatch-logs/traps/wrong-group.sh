# 설명: 로그 그룹을 지정하지 않고 다른 그룹을 보면 건수가 다르다
# 실패해야: OutOfMemoryError 건수
G=$(aws logs describe-log-groups --query 'logGroups[?logGroupName!=`/app/payment-api`].logGroupName | [0]' --output text)
aws logs filter-log-events --log-group-name "$G" --filter-pattern OutOfMemoryError --query 'events[].message' --output text | tr '\t' '\n' | sed '/^$/d' | wc -l > ~/count.txt
