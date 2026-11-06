# 설명: --expires-in 을 빼면 기본 1시간짜리 링크가 된다
# 실패해야: 유효기간이 24시간
B=$(grep -oE 'finance-docs-[0-9]+' ~/request.txt)
aws s3 presign "s3://$B/reports/2026-10-settlement.xlsx" > ~/share-url.txt
