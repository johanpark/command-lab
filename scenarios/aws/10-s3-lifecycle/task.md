# 계속 쌓이는 로그 버킷 정리 규칙 (S3 수명 주기)

S3 요금을 보니 **로그 버킷**이 제일 비싸요. 서비스 시작부터 몇 년치 로그가 한 번도 안 지워지고 쌓여 있대요. 파일을 손으로 지우는 대신 **수명 주기(lifecycle) 규칙**을 걸면 S3 가 알아서 옮기고 지워 줘요.

버킷 이름은 `~/bucket.txt` 에 있고, 안에는 이런 경로들이 있어요.
```
logs/app/2023-01-01.log.gz ...
logs/nginx/2023-01-01.log.gz ...
tmp/upload-xxxx.part ...
backups/db-2025-12-31.sql.gz ...
```

## 목표 (회사 보관 정책)
| 경로 | 규칙 |
|---|---|
| `logs/` | 만든 지 **30일** 뒤 `GLACIER` 로 옮기고, **365일** 뒤 삭제 |
| `tmp/` | **7일** 뒤 삭제 |
| `backups/` | **절대 자동으로 지우거나 옮기면 안 됨** (법적 보관) |

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws s3 ls s3://버킷/` | 경로 확인 |
| `aws s3api put-bucket-lifecycle-configuration --bucket 버킷 --lifecycle-configuration file://규칙.json` | 규칙 걸기 (**기존 규칙 전체를 덮어씀**) |
| `aws s3api get-bucket-lifecycle-configuration --bucket 버킷` | 지금 규칙 보기 |

규칙 JSON 모양:
```json
{
  "Rules": [
    {
      "ID": "규칙 이름",
      "Status": "Enabled",
      "Filter": { "Prefix": "경로/" },
      "Transitions": [ { "Days": 30, "StorageClass": "GLACIER" } ],
      "Expiration": { "Days": 365 }
    }
  ]
}
```
