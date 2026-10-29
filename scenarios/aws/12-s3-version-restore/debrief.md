# 해설

```bash
B=$(aws s3api list-buckets --query "Buckets[?starts_with(Name,'config-')].Name" --output text)
V=$(aws s3api list-object-versions --bucket "$B" --prefix prod/app.json \
  --query "sort_by(Versions[?Key=='prod/app.json'],&LastModified)[-2].VersionId" --output text)
aws s3api copy-object --bucket "$B" --key prod/app.json --copy-source "$B/prod/app.json?versionId=$V"

M=$(aws s3api list-object-versions --bucket "$B" --prefix prod/feature-flags.json \
  --query "DeleteMarkers[?IsLatest].VersionId" --output text)
aws s3api delete-object --bucket "$B" --key prod/feature-flags.json --version-id "$M"
```

## 버전 관리 버킷에서 일어나는 일
| 한 일 | 실제로 생기는 것 |
|---|---|
| 같은 키에 업로드 | 새 버전이 위에 쌓임 (옛 버전은 그대로) |
| 그냥 삭제 (`aws s3 rm`) | **삭제 마커**가 맨 위에 생김 → 목록에서 안 보이지만 데이터는 있음 |
| `--version-id` 로 삭제 | 그 버전을 **영구 삭제** (되돌릴 수 없음) |
| 삭제 마커를 `--version-id` 로 삭제 | 마커가 사라지고 바로 아래 버전이 다시 최신 |

## 왜 "복사로 되돌리기" 인가
- 깨진 버전을 영구 삭제해도 결과는 같아 보이지만, **무슨 일이 있었는지 증거가 사라져요.** 복사는 "정상 버전을 다시 올렸다" 는 기록이 하나 더 쌓일 뿐이에요.
- 깨진 파일이 여러 번 덮어써졌다면 "몇 번째 전" 이 아니라 **내용을 확인해서** 고르세요. 오래된 버전으로 되돌리면 그 사이의 정상 변경(이번엔 1.4 의 `max_connections`)까지 날아가요.

## 실무 팁
- 설정·백업 버킷은 **처음부터 버전 관리를 켜 두세요.** 사고가 난 뒤에 켜면 이미 늦어요.
- 옛 버전이 끝없이 쌓이면 요금이 늘어요 → 수명 주기 규칙의 `NoncurrentVersionExpiration` 으로 "이전 버전은 90일 뒤 삭제" 같은 정리를 걸어요.
- 실수로 영구 삭제하는 것까지 막고 싶다면 **MFA Delete** 나 **Object Lock** 을 써요.
