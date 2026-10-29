# 해설

```bash
G=/app/payment-api
aws logs filter-log-events --log-group-name $G --filter-pattern OutOfMemoryError \
  --query 'events[].logStreamName' --output text | tr '\t' '\n' | sort | uniq -c
# → 9 i-0abc...   (한 서버에 몰림)
aws logs filter-log-events --log-group-name $G --filter-pattern OutOfMemoryError \
  --query 'events[].message' --output text | tr '\t' '\n' | wc -l > ~/count.txt
```

## filter-pattern 문법 맛보기
| 패턴 | 뜻 |
|---|---|
| `ERROR` | ERROR 가 든 줄 |
| `"Out of memory"` | 띄어쓰기 포함 문구 그대로 |
| `ERROR -declined` | ERROR 는 있고 declined 는 없는 줄 |
| `?ERROR ?WARN` | 둘 중 하나라도 |
| `{ $.level = "error" }` | JSON 로그의 필드로 |

## 더 강력한 도구: Logs Insights
여러 그룹을 SQL 비슷한 문법으로 집계할 수 있어요 (웹 콘솔 또는 `aws logs start-query`).
```
fields @timestamp, @logStream, @message
| filter @message like /OutOfMemoryError/
| stats count() by @logStream
```

## 실무 팁
- 에러 로그 개수에 **지표 필터(metric filter)** 를 걸고 **알람**을 만들면, 사람이 보기 전에 알림이 와요.
- 로그 보관 기간(retention)을 정하지 않으면 **영원히 쌓여서** 요금이 계속 나가요: `aws logs put-retention-policy --retention-in-days 30`
- 이 경우 한 서버만 메모리가 부족하다면 그 서버의 메모리 누수나 쏠린 트래픽을 의심해요. 인스턴스 타입을 올리기 전에 원인부터!
