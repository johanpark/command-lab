# 해설

```bash
B=$(grep backups ~/buckets.txt); W=$(grep website ~/buckets.txt)
aws s3 cp ~/backup/db-2026-10-29/ "s3://$B/db/2026-10-29/" --recursive
aws s3 sync ~/site/ "s3://$W/" --delete --exclude 'drafts/*' --dryrun   # 먼저 확인
aws s3 sync ~/site/ "s3://$W/" --delete --exclude 'drafts/*'
```

## cp --recursive vs sync
| | `cp --recursive` | `sync` |
|---|---|---|
| 무엇을 | 전부 올림 | **바뀐 것만** (크기·시각 비교) |
| 지우기 | 안 함 | `--delete` 를 주면 반대편에만 있는 것 삭제 |
| 쓰임 | 한 번 올리는 백업 | 웹사이트 배포, 폴더 미러링 |

`aws s3 sync s3://버킷/경로/ ./로컬/` 처럼 반대 방향(내려받기)도 돼요.

## S3 의 "폴더" 는 진짜 폴더가 아니에요
S3 에는 폴더가 없고, 파일 이름(key) 안에 `/` 가 들어 있을 뿐이에요. `db/2026-10-29/dump.sql.gz` 가 통째로 하나의 이름이에요. 그래서 경로를 잘못 쓰면 `db/2026-10-29/db-2026-10-29/dump.sql.gz` 처럼 한 겹 더 들어가요.

## --delete 는 --dryrun 과 짝꿍
`--delete` 를 경로 실수와 함께 쓰면 버킷이 통째로 비워질 수 있어요. 항상 `--dryrun` 으로 먼저 보는 습관을 들이세요. 실수에 대비해 중요한 버킷은 **버전 관리(versioning)** 를 켜 두면 지운 파일도 되살릴 수 있어요.

## 실무 팁
- 백업 버킷에는 **수명 주기 규칙**(lifecycle)으로 30일 지난 파일을 자동 삭제하거나 저렴한 저장 등급(Glacier)으로 옮겨요.
- 웹사이트는 보통 S3 앞에 **CloudFront** 를 두는데, 파일을 바꾼 뒤 캐시를 비워야(`aws cloudfront create-invalidation`) 새 내용이 보여요.
