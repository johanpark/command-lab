한 사람의 현재 상태를 한눈에:
```
u=park-...
aws iam get-login-profile --user-name $u
aws iam list-access-keys --user-name $u --query "AccessKeyMetadata[].[AccessKeyId,Status]" --output table
aws iam list-groups-for-user --user-name $u --query "Groups[].GroupName"
aws iam list-attached-user-policies --user-name $u --query "AttachedPolicies[].PolicyArn"
aws iam list-user-policies --user-name $u
```
---
권한은 **세 군데**에서 와요: 그룹에 붙은 정책, 사용자에게 직접 붙은 **관리형** 정책, 사용자 안에 들어 있는 **인라인** 정책.
관리형은 `detach-user-policy --policy-arn`, 인라인은 `delete-user-policy --policy-name` 이에요.
---
키가 여러 개일 수 있으니 반복문으로:
`for k in $(aws iam list-access-keys --user-name $u --query 'AccessKeyMetadata[].AccessKeyId' --output text); do aws iam update-access-key --user-name $u --access-key-id $k --status Inactive; done`
그룹·정책도 같은 모양으로 반복하면 돼요.
---
마지막으로 `aws iam tag-user --user-name $u --tags Key=Status,Value=offboarded`. 두 사람 모두 했는지 확인!
