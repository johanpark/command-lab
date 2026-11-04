# 설명: uniq -c 결과를 그대로 적으면 앞에 건수까지 붙는다 (스트림 이름만 적어야 함)
# 실패해야: 에러가 난 서버(로그 스트림)
G=/app/payment-api
aws logs filter-log-events --log-group-name $G --filter-pattern OutOfMemoryError --query 'events[].message' --output text | tr '\t' '\n' | sed '/^$/d' | wc -l > ~/count.txt
aws logs filter-log-events --log-group-name $G --filter-pattern OutOfMemoryError --query 'events[].logStreamName' --output text | tr '\t' '\n' | sort | uniq -c | sort -rn | head -n 1 > ~/answer.txt
