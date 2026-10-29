B=$(grep backups ~/buckets.txt); W=$(grep website ~/buckets.txt)
aws s3 cp ~/backup/db-2026-10-29/ "s3://$B/db/2026-10-29/" --recursive --only-show-errors
aws s3 sync ~/site/ "s3://$W/" --delete --exclude 'drafts/*' --only-show-errors
aws s3 ls "s3://$W/" --recursive
