# 해설

```bash
FN=" $(aws lambda list-functions --query 'Functions[].FunctionName' --output text | tr '\t' ' ') "
for g in $(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/ --query 'logGroups[].logGroupName' --output text); do
  if [[ "$FN" == *" ${g#/aws/lambda/} "* ]]; then        # 앞뒤 공백까지 비교 = 이름 전체가 같은지
    aws logs put-retention-policy --log-group-name "$g" --retention-in-days 14
  else
    aws logs delete-log-group --log-group-name "$g"
  fi
done
for g in $(aws logs describe-log-groups --log-group-name-prefix /shop/app/ --query 'logGroups[].logGroupName' --output text); do
  aws logs put-retention-policy --log-group-name "$g" --retention-in-days 30
done
# 감사 로그: 짧거나 없는 것만 400 으로 (더 긴 건 그대로)
for g in $(aws logs describe-log-groups --log-group-name-prefix /shop/audit/ \
    --query 'logGroups[?!retentionInDays || retentionInDays < `400`].logGroupName' --output text); do
  aws logs put-retention-policy --log-group-name "$g" --retention-in-days 400
done
```

## 왜 로그 그룹이 "만료 안 함" 으로 생길까
람다 함수가 처음 로그를 쓰면 `/aws/lambda/함수이름` 그룹이 **자동으로** 생기는데, 이때 보존 기간이 "만료 안 함" 이에요. 함수를 지워도 로그 그룹은 남아요. 그래서 시간이 지나면 주인 없는 로그 그룹이 잔뜩 쌓여요.
→ 함수를 만들 때 IaC(CloudFormation·Terraform·SAM)로 로그 그룹도 같이 만들고 보존 기간을 지정해 두면 이런 일이 없어요.

## 보존 기간은 정해진 값만
`1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, ...` 이 중에서만 고를 수 있어요. "35일" 은 `InvalidParameterException`.

## 지우기 전에 한 번 더
- `delete-log-group` 은 그 안의 로그를 **전부, 즉시** 지워요. 되돌릴 수 없어요.
- 이름이 비슷한 함수(`order-api` vs `order-api-old`)를 부분 일치로 비교하면 살아 있는 함수의 로그를 지울 수 있어요. 항상 **전체 이름**으로.
- 법적 보관 의무가 있는 로그(감사, 결제)는 보존 기간을 **늘리는 쪽**만 자동화하세요. 오래 보관해야 하면 S3 로 내보내고(`create-export-task`) S3 수명 주기로 Glacier 에 두는 게 훨씬 싸요.
