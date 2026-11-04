# 설명: --delete 와 --exclude 를 빼면 옛 파일이 남고 초안까지 올라간다
# 실패해야: 옛 파일이 버킷에 남아 있지 않다
# 실패해야: 초안(drafts/)은 올라가지 않았다
B=$(grep backups ~/buckets.txt); W=$(grep website ~/buckets.txt)
aws s3 cp ~/backup/db-2026-10-29/ "s3://$B/db/2026-10-29/" --recursive --only-show-errors
aws s3 sync ~/site/ "s3://$W/" --only-show-errors
