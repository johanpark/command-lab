# 설명: 끝 슬래시 없이 폴더를 올리면 db-2026-10-29/ 가 한 겹 더 들어간다
# 실패해야: 한 겹 더 들어갔어요
B=$(grep backups ~/buckets.txt); W=$(grep website ~/buckets.txt)
aws s3 cp ~/backup/db-2026-10-29 "s3://$B/db/2026-10-29/db-2026-10-29/" --recursive --only-show-errors
aws s3 sync ~/site/ "s3://$W/" --delete --exclude 'drafts/*' --only-show-errors
