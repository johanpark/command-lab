# 설명: 한국 시간 04시를 그대로 cron 에 넣으면 UTC 04시 = 한국 13시에 돈다
# 실패해야: log-cleanup 이 한국 시간 매일 04:00
M=$(grep -oE '03:[0-9]{2}' ~/schedule.md | head -1 | cut -d: -f2)
aws events put-rule --name log-cleanup --schedule-expression "cron(0 4 * * ? *)" >/dev/null
aws events put-rule --name nightly-sales-report --schedule-expression "cron($M 18 ? * SUN-THU *)" >/dev/null
Q=$(aws sqs get-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name report-jobs --query QueueUrl --output text)" \
  --attribute-names QueueArn --query Attributes.QueueArn --output text)
aws events put-targets --rule nightly-sales-report --targets "Id=report,Arn=$Q" >/dev/null
