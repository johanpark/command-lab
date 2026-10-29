`cat ~/buckets.txt` 로 버킷 이름을 확인하고, `aws s3 ls s3://웹사이트버킷/ --recursive` 로 지금 사이트에 뭐가 있는지 보세요. 로컬 `~/site` 와 비교하면 버킷에만 있는 옛 파일이 보여요.
---
백업: `aws s3 cp ~/backup/db-2026-10-29/ s3://백업버킷/db/2026-10-29/ --recursive`. 끝에 `/` 를 붙여서 **폴더 안의 파일들**이 그 경로로 가게 하세요. 확인: `aws s3 ls s3://백업버킷/db/2026-10-29/`
---
웹사이트: `aws s3 sync ~/site/ s3://웹사이트버킷/ --delete --exclude 'drafts/*' --dryrun` 으로 먼저 계획을 보세요. `upload:` 와 `delete:` 줄이 원하는 대로인지 확인!
---
⚠️ `--delete` 는 버킷에서 파일을 지워요. `--dryrun` 결과에 남겨야 할 파일이 `delete:` 로 나오면 경로(버킷 뒤 `/`)나 `--exclude` 를 다시 보세요. 괜찮으면 `--dryrun` 을 빼고 실행.
