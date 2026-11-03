# 설명: 대상을 다른 큐로 두고 weekly-invoice 까지 바꾼다
# 실패해야: report-jobs 큐를 깨운다
# 실패해야: weekly-invoice 는 그대로다
M=$(grep -oE '03:[0-9]{2}' ~/schedule.md | head -1 | cut -d: -f2)
aws events put-rule --name log-cleanup --schedule-expression "cron(0 19 * * ? *)" >/dev/null
aws events put-rule --name nightly-sales-report --schedule-expression "cron($M 18 ? * SUN-THU *)" >/dev/null
Q=$(aws sqs get-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name log-cleanup-jobs --query QueueUrl --output text)" \
  --attribute-names QueueArn --query Attributes.QueueArn --output text)
aws events put-targets --rule nightly-sales-report --targets "Id=report,Arn=$Q" >/dev/null
aws events put-rule --name weekly-invoice --schedule-expression "cron(0 9 ? * MON *)" >/dev/null
