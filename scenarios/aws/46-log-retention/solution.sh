FN=" $(aws lambda list-functions --query 'Functions[].FunctionName' --output text | tr '\t' ' ') "
for g in $(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/ --query 'logGroups[].logGroupName' --output text); do
  if [[ "$FN" == *" ${g#/aws/lambda/} "* ]]; then aws logs put-retention-policy --log-group-name "$g" --retention-in-days 14
  else aws logs delete-log-group --log-group-name "$g"; fi
done
for g in $(aws logs describe-log-groups --log-group-name-prefix /shop/app/ --query 'logGroups[].logGroupName' --output text); do
  aws logs put-retention-policy --log-group-name "$g" --retention-in-days 30
done
for g in $(aws logs describe-log-groups --log-group-name-prefix /shop/audit/ --query 'logGroups[?!retentionInDays || retentionInDays < `400`].logGroupName' --output text); do
  aws logs put-retention-policy --log-group-name "$g" --retention-in-days 400
done
