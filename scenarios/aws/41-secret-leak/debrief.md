# 해설

```bash
P=$(aws secretsmanager get-random-password --password-length 32 --exclude-punctuation --query RandomPassword --output text)
aws rds modify-db-instance --db-instance-identifier shop-db --master-user-password "$P" --apply-immediately
aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text \
  | jq -c --arg p "$P" '.password = $p' > new.json
aws secretsmanager put-secret-value --secret-id prod/shop/db --secret-string file://new.json && rm new.json
```

## 버전 라벨
```
put-secret-value 전:  v1 [AWSCURRENT]
put-secret-value 후:  v1 [AWSPREVIOUS]   v2 [AWSCURRENT]
한 번 더 하면:         v1 []  v2 [AWSPREVIOUS]   v3 [AWSCURRENT]
```
앱은 보통 AWSCURRENT 를 읽어요. AWSPREVIOUS 는 교체 중 문제가 생기면 되돌리거나, 사고 기록을 남기는 용도예요.

## 순서와 끊김
DB 를 먼저 바꾸면 비밀이 바뀌기 전까지, 비밀을 먼저 바꾸면 DB 가 바뀌기 전까지 **새로 접속하는 앱이 실패**할 수 있어요 (이미 열린 연결은 유지). 그래서 몇 초 안에 둘을 연달아 하거나, 아예 Secrets Manager 의 **자동 교체(rotation)** 를 써서 AWS 가 이 과정을 안전하게 하게 만들어요.

## 실무 팁
- RDS 는 `--manage-master-user-password` 로 마스터 비밀번호 자체를 Secrets Manager 가 관리하고 자동 교체하게 할 수 있어요. 사람이 비밀번호를 볼 일이 없어져요.
- 노출된 비밀은 교체만으로 끝나지 않아요. 노출된 동안 **누가 접속했는지** DB 접속 로그와 CloudTrail(`GetSecretValue` 호출)을 확인하세요.
- 비밀 값을 터미널에 띄우지 않는 습관: `--query` 로 필요한 필드만 변수에 담고, 화면 공유·캡처 전에 터미널을 정리하세요.
