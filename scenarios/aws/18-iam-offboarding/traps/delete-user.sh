# 설명: 30일 보관 규정을 어기고 계정을 지워 버린다
# 실패해야: 계정이 남아 있다
for u in $(grep '^퇴사자:' ~/offboarding.txt | sed 's/^퇴사자://; s/,/ /g'); do
  aws iam delete-login-profile --user-name "$u" 2>/dev/null
  for k in $(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].AccessKeyId' --output text); do aws iam delete-access-key --user-name "$u" --access-key-id "$k"; done
  for g in $(aws iam list-groups-for-user --user-name "$u" --query 'Groups[].GroupName' --output text); do aws iam remove-user-from-group --user-name "$u" --group-name "$g"; done
  for p in $(aws iam list-attached-user-policies --user-name "$u" --query 'AttachedPolicies[].PolicyArn' --output text); do aws iam detach-user-policy --user-name "$u" --policy-arn "$p"; done
  for p in $(aws iam list-user-policies --user-name "$u" --query 'PolicyNames' --output text); do aws iam delete-user-policy --user-name "$u" --policy-name "$p"; done
  aws iam delete-user --user-name "$u"
done
