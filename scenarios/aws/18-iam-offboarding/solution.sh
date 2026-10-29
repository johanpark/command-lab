for u in $(grep '^퇴사자:' ~/offboarding.txt | sed 's/^퇴사자://; s/,/ /g'); do
  aws iam delete-login-profile --user-name "$u"
  for k in $(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
    aws iam update-access-key --user-name "$u" --access-key-id "$k" --status Inactive
  done
  for g in $(aws iam list-groups-for-user --user-name "$u" --query 'Groups[].GroupName' --output text); do
    aws iam remove-user-from-group --user-name "$u" --group-name "$g"
  done
  for p in $(aws iam list-attached-user-policies --user-name "$u" --query 'AttachedPolicies[].PolicyArn' --output text); do
    aws iam detach-user-policy --user-name "$u" --policy-arn "$p"
  done
  for p in $(aws iam list-user-policies --user-name "$u" --query 'PolicyNames' --output text); do
    aws iam delete-user-policy --user-name "$u" --policy-name "$p"
  done
  aws iam tag-user --user-name "$u" --tags Key=Status,Value=offboarded
done
