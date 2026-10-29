B=$(aws s3api list-buckets --query "Buckets[?starts_with(Name,'config-')].Name" --output text)
# app.json: 최신(깨진) 것 바로 전 버전을 최신으로 복사
V=$(aws s3api list-object-versions --bucket "$B" --prefix prod/app.json \
  --query "sort_by(Versions[?Key=='prod/app.json'],&LastModified)[-2].VersionId" --output text)
aws s3api copy-object --bucket "$B" --key prod/app.json --copy-source "$B/prod/app.json?versionId=$V" >/dev/null
# feature-flags.json: 맨 위의 삭제 마커만 지우면 이전 버전이 다시 보인다
M=$(aws s3api list-object-versions --bucket "$B" --prefix prod/feature-flags.json \
  --query "DeleteMarkers[?IsLatest].VersionId" --output text)
aws s3api delete-object --bucket "$B" --key prod/feature-flags.json --version-id "$M" >/dev/null
