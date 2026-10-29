`aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text` 로 그룹 이름부터 확인하세요. `/app/payment-api` 말고 다른 그룹에도 비슷한 에러가 있어요.
---
그룹 전체(서버 전부)에서 한 번에 찾기: `aws logs filter-log-events --log-group-name /app/payment-api --filter-pattern OutOfMemoryError --query 'events[].[logStreamName, message]' --output text`
---
개수: 위 명령에 `| wc -l`. 서버: `--query 'events[].logStreamName' --output text | tr '\t' '\n' | sort | uniq -c` 로 스트림별 개수를 보면 한 서버에 몰려 있어요.
---
`... | wc -l > ~/count.txt`, 스트림 이름을 `~/answer.txt` 에. `ERROR` 로 찾으면 카드 거절 같은 다른 에러까지 섞이니 꼭 `OutOfMemoryError` 로!
