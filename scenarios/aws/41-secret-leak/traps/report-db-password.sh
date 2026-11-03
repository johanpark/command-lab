# 설명: 건드리지 말라던 report-db 의 비밀번호를 바꾼다
# 모범 풀이 먼저
# 실패해야: report-db 는 그대로다
aws rds modify-db-instance --db-instance-identifier report-db --master-user-password Other12345678 --apply-immediately
