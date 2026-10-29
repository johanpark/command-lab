B=$(grep -oE 'finance-docs-[0-9]+' ~/request.txt)
aws s3 presign "s3://$B/reports/2026-10-settlement.xlsx" --expires-in 86400 > ~/share-url.txt
