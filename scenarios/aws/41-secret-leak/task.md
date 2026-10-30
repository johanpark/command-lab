# DB 비밀번호가 슬랙에 올라갔어요 — 긴급 교체 (Secrets Manager·RDS)

운영 DB 접속 정보가 담긴 터미널 화면 캡처가 사내 메신저에 올라갔어요. 바로 지웠지만 **이미 본 사람이 있을 수 있어요.**
사고 메모와 보안팀 요구 사항은 `~/incident.md` 에 있어요.

## 목표
1. **`get-random-password`** 로 **32자, 특수문자 없는** 새 비밀번호를 만드세요.
2. RDS **`shop-db`** 의 마스터 비밀번호를 그 값으로 바꾸세요. (바로 적용)
3. Secrets Manager **`prod/shop/db`** 의 **`password` 만** 새 값으로 바꾸세요. 다른 필드는 그대로.
4. 옛 값은 **`AWSPREVIOUS`** 버전에만 남아 있어야 해요.
5. `report-db`, `prod/report/db` 는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws secretsmanager get-random-password --password-length 32 --exclude-punctuation --query RandomPassword --output text` | 안전한 무작위 비밀번호 |
| `aws secretsmanager get-secret-value --secret-id 이름 --query SecretString --output text` | 지금 값 (JSON 글자) |
| `aws secretsmanager put-secret-value --secret-id 이름 --secret-string file://new.json` | 새 버전 저장 (이전 값은 AWSPREVIOUS 로) |
| `aws secretsmanager describe-secret --secret-id 이름 --query VersionIdsToStages` | 버전과 라벨 |
| `aws rds modify-db-instance --db-instance-identifier shop-db --master-user-password 새값 --apply-immediately` | DB 비밀번호 바꾸기 |

> ⚠️ 이번 사고처럼, 비밀 값을 화면에 띄우면 캡처나 터미널 기록으로 새요. 값을 **변수나 파일로만** 다루고 `echo` 하지 마세요.
