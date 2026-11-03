# 설명: 허용되지 않는 보존 기간(35일)은 거부된다 → 아무것도 바뀌지 않는다
# 실패해야: /shop/app/* 은 30일
aws logs put-retention-policy --log-group-name /shop/app/web --retention-in-days 35
