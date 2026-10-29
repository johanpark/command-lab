파일 목록: `aws s3 ls s3://finance-docs-XXXX/ --recursive` → `reports/` 에서 10월 **확정본**(draft 아닌 것)을 찾으세요.
---
`aws s3 presign s3://버킷/키 --expires-in 초` 가 URL 을 출력해요. 24시간은 몇 초일까요? (`echo $((24*60*60))`)
---
`aws s3 presign ... > ~/share-url.txt` 로 바로 저장하고, `curl -s -o /dev/null -w '%{http_code}\n' "$(cat ~/share-url.txt)"` 로 200 이 나오는지 확인해 보세요.
