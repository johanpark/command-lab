# 설명: 일을 ? 로, 요일을 * 로 쓰거나 요일을 숫자(1-5 = 일~목)로 써도 맞는 풀이다
# 통과해야
M=$(grep -oE '03:[0-9]{2}' ~/schedule.md | head -1 | cut -d: -f2)
aws events put-rule --name log-cleanup --schedule-expression "cron(0 19 ? * * *)" >/dev/null
aws events put-rule --name nightly-sales-report --schedule-expression "cron($M 18 ? * 1-5 *)" >/dev/null
Q=$(aws sqs get-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name report-jobs --query QueueUrl --output text)" \
  --attribute-names QueueArn --query Attributes.QueueArn --output text)
aws events put-targets --rule nightly-sales-report --targets "Id=report,Arn=$Q" >/dev/null
