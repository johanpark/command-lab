# 서울 리전이 멈춰도 주문 기록은 남게 (S3 교차 리전 복제)

재해 대비 감사에서 "주문 기록이 서울 리전 한 곳에만 있다" 는 지적을 받았어요. 계획은 `~/dr-plan.md` 에 있어요.
S3 **복제(Replication)** 를 설정하면, 원본 버킷에 새 파일이 올라올 때마다 다른 리전의 버킷으로 자동 복사돼요.

## 목표
1. 원본과 복제본 버킷 **둘 다 버전 관리**를 켜세요. (복제의 필수 조건)
2. 원본 버킷에 복제 규칙을 거세요.
   - IAM 역할: `s3-replication-role`
   - **`orders/` 아래만** 복제
   - 대상: 복제본 버킷, 저장 클래스 **STANDARD_IA**
   - **삭제 마커는 복제하지 않기**
   - 규칙은 **켜진(Enabled)** 상태

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws s3api get-bucket-location --bucket 버킷` | 버킷이 있는 리전 |
| `aws s3api put-bucket-versioning --bucket 버킷 --versioning-configuration Status=Enabled` | 버전 관리 켜기 |
| `aws iam get-role --role-name 이름 --query Role.Arn` | 역할 ARN |
| `aws s3api put-bucket-replication --bucket 원본 --replication-configuration file://repl.json` | 복제 규칙 |
| `aws s3api get-bucket-replication --bucket 원본` | 확인 |

`repl.json` 모양:
```json
{"Role": "arn:aws:iam::...:role/...",
 "Rules": [{"ID": "이름", "Status": "Enabled", "Priority": 1,
            "Filter": {"Prefix": "..."},
            "DeleteMarkerReplication": {"Status": "Enabled|Disabled"},
            "Destination": {"Bucket": "arn:aws:s3:::버킷", "StorageClass": "..."}}]}
```
