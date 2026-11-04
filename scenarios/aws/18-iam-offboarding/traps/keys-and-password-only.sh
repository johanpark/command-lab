# 설명: 로그인·키만 막고 그룹·정책을 그대로 두면 다시 켜는 순간 권한이 되살아난다
# 실패해야: 어느 그룹에도 없다
# 실패해야: 직접 붙은 정책이 없다
for u in $(grep '^퇴사자:' ~/offboarding.txt | sed 's/^퇴사자://; s/,/ /g'); do
  aws iam delete-login-profile --user-name "$u" 2>/dev/null
  for k in $(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].AccessKeyId' --output text); do aws iam update-access-key --user-name "$u" --access-key-id "$k" --status Inactive; done
  aws iam tag-user --user-name "$u" --tags Key=Status,Value=offboarded
done
