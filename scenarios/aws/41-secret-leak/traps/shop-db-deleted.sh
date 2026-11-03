# 설명: shop-db 를 지워 버린다
# 모범 풀이 먼저
# 실패해야: shop-db 가 없어요
aws rds delete-db-instance --db-instance-identifier shop-db --skip-final-snapshot
