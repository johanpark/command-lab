# 설명: 시각만 UTC 로 바꾸고 요일은 MON-FRI 그대로 두면 한국 화~토에 돈다
# 실패해야: 하루 밀렸어요
M=$(grep -oE '03:[0-9]{2}' ~/schedule.md | head -1 | cut -d: -f2)
aws events put-rule --name log-cleanup --schedule-expression "cron(0 19 * * ? *)" >/dev/null
aws events put-rule --name nightly-sales-report --schedule-expression "cron($M 18 ? * MON-FRI *)" >/dev/null
Q=$(aws sqs get-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name report-jobs --query QueueUrl --output text)" \
  --attribute-names QueueArn --query Attributes.QueueArn --output text)
aws events put-targets --rule nightly-sales-report --targets "Id=report,Arn=$Q" >/dev/null
