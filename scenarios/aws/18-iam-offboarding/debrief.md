# 해설

```bash
for u in park-... lee-...; do
  aws iam delete-login-profile --user-name $u                       # 콘솔 로그인 차단
  for k in $(aws iam list-access-keys --user-name $u --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
    aws iam update-access-key --user-name $u --access-key-id $k --status Inactive   # 키는 남기고 끄기
  done
  for g in $(aws iam list-groups-for-user --user-name $u --query 'Groups[].GroupName' --output text); do
    aws iam remove-user-from-group --user-name $u --group-name $g
  done
  for p in $(aws iam list-attached-user-policies --user-name $u --query 'AttachedPolicies[].PolicyArn' --output text); do
    aws iam detach-user-policy --user-name $u --policy-arn $p
  done
  for p in $(aws iam list-user-policies --user-name $u --query PolicyNames --output text); do
    aws iam delete-user-policy --user-name $u --policy-name $p
  done
  aws iam tag-user --user-name $u --tags Key=Status,Value=offboarded
done
```

## 왜 바로 지우지 않나
- CloudTrail 로그에는 **액세스 키 ID** 가 남아요. 나중에 "이 키가 퇴사 직전에 뭘 했지?" 를 확인할 때 키·사용자 정보가 있으면 추적이 쉬워요.
- 혹시 그 사람의 키를 **어떤 서버나 스크립트가 몰래 쓰고 있었다면**, 비활성화 후 에러가 나는 곳을 보고 찾아낼 수 있어요. 지웠으면 되살릴 수 없지만 비활성은 잠깐 다시 켤 수 있어요.

## 나중에 진짜 지울 때 (실제 AWS)
IAM 사용자는 딸린 것이 하나라도 있으면 `DeleteConflict` 로 삭제가 거부돼요. 순서대로 다 떼야 해요:
로그인 프로필 → 액세스 키 → 서명 인증서·SSH 키·서비스 자격 증명 → MFA 장치 → 그룹 → 관리형 정책 → 인라인 정책 → **delete-user**
(이 실습의 가짜 AWS 는 이 검사를 일부만 흉내 내요)

## 실무 팁
- 사람마다 IAM 사용자를 만드는 대신 **IAM Identity Center(SSO)** 로 회사 계정과 연결하면, 인사 시스템에서 퇴사 처리하는 순간 AWS 접근도 같이 끊겨요.
- `aws iam generate-credential-report` 로 전체 사용자의 비밀번호·키 마지막 사용일을 CSV 로 받아, 오래 안 쓴 계정을 정기적으로 찾을 수 있어요.
