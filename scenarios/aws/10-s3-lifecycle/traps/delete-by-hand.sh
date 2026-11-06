# 설명: 규칙 대신 오래된 파일을 손으로 지우면 앞으로 쌓이는 건 그대로다
# 실패해야: 손으로 지우지 않음
# 실패해야: 수명 주기 규칙이 걸려 있다
B=$(cat ~/bucket.txt)
aws s3 rm "s3://$B/tmp/" --recursive --only-show-errors
