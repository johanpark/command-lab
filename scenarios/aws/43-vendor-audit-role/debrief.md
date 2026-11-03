# 해설

```bash
cat > trust.json <<JSON
{"Version": "2012-10-17",
 "Statement": [{"Effect": "Allow",
                "Principal": {"AWS": "arn:aws:iam::업체계정ID:root"},
                "Action": "sts:AssumeRole",
                "Condition": {"StringEquals": {"sts:ExternalId": "약속한 외부 ID"}}}]}
JSON
aws iam create-role --role-name vendor-audit --assume-role-policy-document file://trust.json --max-session-duration 3600
aws iam attach-role-policy --role-name vendor-audit --policy-arn arn:aws:iam::aws:policy/SecurityAudit
aws iam update-access-key --user-name vendor-audit-2025 --access-key-id AKIA... --status Inactive
```

## 업체는 이렇게 들어와요
```bash
# 업체 계정에서 실행
aws sts assume-role --role-arn arn:aws:iam::우리계정:role/vendor-audit \
  --role-session-name audit-kim --external-id 약속한값
# → 1시간짜리 임시 키(AccessKeyId·SecretAccessKey·SessionToken)가 나온다
```
키가 유출돼도 1시간 뒤면 쓸모가 없고, 감사가 끝나면 역할만 지우면 끝이에요. 작년처럼 **영구 키**가 메일함에 남아 있는 일이 없어요.

## 외부 ID 는 왜 필요할까 (혼동된 대리인 문제)
업체는 고객사 여러 곳의 역할을 맡아요. 외부 ID 가 없으면, 다른 고객이 **우리 역할 ARN** 을 자기 것이라고 업체에 등록해서 업체를 통해 우리 계정을 들여다볼 수 있어요. 고객마다 다른 외부 ID 를 약속해 두면 업체가 남의 역할을 대신 맡아 주는 실수를 막을 수 있어요.
- 조건은 `StringEquals` 로. `StringEqualsIfExists` 는 외부 ID 를 **안 보내면 통과**라서 의미가 없어요.

## SecurityAudit vs ReadOnlyAccess
| 정책 | 볼 수 있는 것 |
|---|---|
| **SecurityAudit** | 보안 설정(IAM, 보안 그룹, 버킷 정책, 로그 설정 등). **S3 객체 내용·DB 데이터는 못 봄** |
| ReadOnlyAccess | 거의 모든 것을 읽기. S3 객체 다운로드, DynamoDB 조회까지 됨 |

감사 업체에게 고객 데이터까지 보여 줄 이유는 없어요. 최소 권한.

## 키는 지우지 말고 끄기
`Inactive` 는 바로 다시 `Active` 로 되돌릴 수 있어요. 지우면 끝이고, "이 키가 언제 마지막으로 쓰였나" 같은 기록(`get-access-key-last-used`)도 같이 사라져요. 몇 주 지켜봐서 아무도 안 찾으면 그때 지워요.
