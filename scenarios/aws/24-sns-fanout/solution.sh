T=$(aws sns list-topics --query "Topics[?ends_with(TopicArn, ':order-events')].TopicArn" --output text)
for q in inventory-updates email-sender; do
  U=$(aws sqs get-queue-url --queue-name $q --query QueueUrl --output text)
  Q=$(aws sqs get-queue-attributes --queue-url "$U" --attribute-names QueueArn --query Attributes.QueueArn --output text)
  jq -n --arg q "$Q" --arg t "$T" '{Policy: ({Version: "2012-10-17", Statement: [{Effect: "Allow",
    Principal: {Service: "sns.amazonaws.com"}, Action: "sqs:SendMessage", Resource: $q,
    Condition: {ArnEquals: {"aws:SourceArn": $t}}}]} | tojson)}' > ~/policy-$q.json
  aws sqs set-queue-attributes --queue-url "$U" --attributes file://$HOME/policy-$q.json
  if [ $q = inventory-updates ]; then
    echo '{"RawMessageDelivery": "true"}' > ~/sub-$q.json
  else
    jq -n '{FilterPolicy: ({event_type: ["order_paid", "order_shipped"]} | tojson)}' > ~/sub-$q.json
  fi
  aws sns subscribe --topic-arn "$T" --protocol sqs --notification-endpoint "$Q" --attributes file://$HOME/sub-$q.json >/dev/null
done
