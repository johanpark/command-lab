G=/app/payment-api
aws logs filter-log-events --log-group-name $G --filter-pattern OutOfMemoryError \
  --query 'events[].message' --output text | tr '\t' '\n' | sed '/^$/d' | wc -l > ~/count.txt
aws logs filter-log-events --log-group-name $G --filter-pattern OutOfMemoryError \
  --query 'events[].logStreamName' --output text | tr '\t' '\n' | sort | uniq -c | sort -rn | head -n 1 | awk '{print $2}' > ~/answer.txt
