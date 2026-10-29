버킷 이름부터: `aws s3 ls`. 그다음 운영 설정의 모든 버전을 표로 봐요:
`aws s3api list-object-versions --bucket 버킷 --prefix prod/ --query "Versions[].[Key,VersionId,IsLatest,LastModified]" --output table`
---
`prod/app.json` 의 버전들을 하나씩 확인해요: `aws s3api get-object --bucket 버킷 --key prod/app.json --version-id 버전ID /tmp/v.json && cat /tmp/v.json`
`jq . /tmp/v.json` 이 에러 없이 출력되면 정상 JSON 이에요. **가장 최근의 정상 버전**을 고르세요 (가장 오래된 것 말고!).
---
되돌리기 = 그 옛 버전을 **같은 키에 다시 복사**해서 새 최신 버전을 만드는 것:
`aws s3api copy-object --bucket 버킷 --key prod/app.json --copy-source "버킷/prod/app.json?versionId=버전ID"`
이렇게 하면 깨진 버전도 기록에 남아요. (깨진 버전을 `--version-id` 로 지우는 건 기록 삭제라 이번엔 안 돼요)
---
`feature-flags.json` 은 **삭제 마커**가 위에 얹힌 상태예요: `--query "DeleteMarkers[].[Key,VersionId,IsLatest]"` 로 마커 ID 를 찾고
`aws s3api delete-object --bucket 버킷 --key prod/feature-flags.json --version-id 마커ID` → 마커가 없어지면서 원래 파일이 다시 보여요.
