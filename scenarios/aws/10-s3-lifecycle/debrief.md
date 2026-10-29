# 해설

```bash
B=$(cat ~/bucket.txt)
aws s3api put-bucket-lifecycle-configuration --bucket $B --lifecycle-configuration file://$HOME/lifecycle.json
aws s3api get-bucket-lifecycle-configuration --bucket $B
```

## 저장 등급과 요금 (대략)
| 등급 | 용도 | 꺼낼 때 |
|---|---|---|
| STANDARD | 자주 읽는 파일 | 바로 |
| STANDARD_IA | 가끔 읽는 파일 (30일 이상 보관) | 바로, 읽기 요금 있음 |
| GLACIER (Flexible Retrieval) | 거의 안 읽는 보관용 | 몇 분~몇 시간 |
| DEEP_ARCHIVE | 법적 보관 | 12시간 안팎 |

로그는 처음 한 달만 자주 보고 그 뒤로는 거의 안 봐요. 그래서 "30일 뒤 싼 곳으로, 1년 뒤 삭제" 가 흔한 패턴이에요.

## 조심할 것
- `put-bucket-lifecycle-configuration` 은 **기존 규칙을 통째로 바꿔요.** 규칙을 하나 추가하려면 `get` 으로 받아서 합친 뒤 다시 `put`.
- 경로가 빈 규칙은 **버킷 전체**에 적용돼요. 지우는 규칙을 걸기 전에 Prefix 를 두 번 확인하세요.
- 규칙은 걸자마자가 아니라 하루에 한 번쯤 S3 가 돌면서 적용해요. 효과는 다음 날부터.
- 버전 관리(versioning)를 켠 버킷은 옛 버전도 쌓여요 → `NoncurrentVersionExpiration` 규칙도 필요해요.
- 실수로 지우면 안 되는 백업은 **Object Lock** 으로 아예 못 지우게 잠글 수도 있어요.
