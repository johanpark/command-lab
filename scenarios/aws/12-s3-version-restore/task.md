# 덮어쓰고 지워버린 설정 파일 되살리기 (S3 버전 관리)

방금 배포 스크립트가 잘못 돌아서 설정 버킷(`config-` 로 시작)의 **운영(`prod/`) 설정**이 망가졌어요.

- `prod/app.json` 이 **중간에 잘린 깨진 JSON** 으로 덮어써졌고,
- `prod/feature-flags.json` 은 **지워졌어요.**

다행히 이 버킷은 **버전 관리(Versioning)** 가 켜져 있어서, 덮어쓰거나 지워도 이전 버전이 남아 있어요.

## 목표
1. `prod/app.json` 을 **깨지기 직전의 정상 버전**으로 되돌리세요.
2. `prod/feature-flags.json` 을 지워지기 전 상태로 되살리세요.
3. 원인 분석에 쓸 거라 **기존 버전 기록은 하나도 지우지 마세요.** (깨진 버전도 남겨 두기)
4. `staging/` 과 다른 파일은 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws s3api get-bucket-versioning --bucket 버킷` | 버전 관리가 켜져 있는지 |
| `aws s3api list-object-versions --bucket 버킷 --prefix prod/` | 파일별 모든 버전과 삭제 마커 |
| `aws s3api get-object --bucket 버킷 --key 키 --version-id 버전 파일` | 특정 버전 내려받기 |
| `aws s3api copy-object --bucket 버킷 --key 키 --copy-source "버킷/키?versionId=버전"` | 옛 버전을 최신으로 복사 |
| `aws s3api delete-object --bucket 버킷 --key 키 --version-id 삭제마커ID` | 삭제 마커 없애기 |

> 💡 버전 관리 버킷에서 그냥 지우면(`aws s3 rm`) 파일이 사라지는 게 아니라 **삭제 마커**가 맨 위에 얹혀요.
