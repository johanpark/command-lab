# 서버에 안 들어가고 로그에서 에러 찾기 (CloudWatch Logs)

결제 API 가 가끔 죽는대요. 결제 API 는 서버(EC2) 여러 대에서 돌고, 각 서버의 로그는 **CloudWatch Logs** 로 모여요. 서버마다 SSH 로 들어가서 로그를 뒤질 필요가 없어요.

CloudWatch Logs 의 구조:
```
로그 그룹 (/app/payment-api)       ← 서비스 하나
 ├── 로그 스트림 (i-0abc...)        ← 서버 한 대
 └── 로그 스트림 (i-0def...)
```

## 목표 (로그 그룹 `/app/payment-api`)
1. 메모리 부족 에러 **`OutOfMemoryError`** 가 찍힌 로그가 **몇 건**인지 → `~/count.txt`
2. 그 에러가 난 **서버(로그 스트림 이름 = 인스턴스 ID)** → `~/answer.txt`

다른 서비스의 로그 그룹도 있으니 헷갈리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws logs describe-log-groups --query 'logGroups[].logGroupName'` | 로그 그룹 목록 |
| `aws logs describe-log-streams --log-group-name 그룹` | 그룹 안 스트림(서버) 목록 |
| `aws logs filter-log-events --log-group-name 그룹 --filter-pattern 단어` | 그룹 전체에서 단어가 든 로그만 |
| `... --query 'events[].[logStreamName, message]' --output text` | 어느 스트림의 어떤 메시지인지 |
| `aws logs get-log-events --log-group-name 그룹 --log-stream-name 스트림 --limit 20` | 스트림 하나의 로그 보기 |
