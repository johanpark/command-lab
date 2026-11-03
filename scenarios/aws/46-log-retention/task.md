# 영원히 쌓이는 로그 요금 줄이기 (CloudWatch Logs 보존 기간)

CloudWatch Logs 요금이 매달 조금씩 늘어요. 확인해 보니 로그 그룹이 전부 **"만료 안 함"** 이라 몇 년 치 로그가 그대로 쌓여 있었어요. 규칙은 `~/log-retention.md` 에 있어요.

로그 그룹마다 **보존 기간(retention)** 을 정해 두면, 그보다 오래된 로그는 AWS 가 알아서 지워요.

## 목표
1. `/aws/lambda/*` → **14일**, `/shop/app/*` → **30일**
2. `/shop/audit/*` → **400일 이상**. 이미 더 길게 잡힌 건 줄이지 마세요.
3. **이제 없는 람다 함수**의 로그 그룹은 삭제하세요.
4. 규칙에 없는 로그 그룹은 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws logs describe-log-groups --query 'logGroups[].[logGroupName,retentionInDays]' --output table` | 로그 그룹과 보존 기간 (`None` = 만료 안 함) |
| `aws logs describe-log-groups --log-group-name-prefix /shop/app/` | 이름이 이렇게 시작하는 것만 |
| `aws logs put-retention-policy --log-group-name 그룹 --retention-in-days 일` | 보존 기간 정하기 |
| `aws logs delete-log-group --log-group-name 그룹` | 로그 그룹 삭제 (로그도 전부 사라짐) |
| `aws lambda list-functions --query 'Functions[].FunctionName' --output text` | 지금 있는 람다 함수 |

> 💡 그룹이 여러 개면 `for g in $(aws logs describe-log-groups ... --output text); do ...; done` 으로 반복하세요.
