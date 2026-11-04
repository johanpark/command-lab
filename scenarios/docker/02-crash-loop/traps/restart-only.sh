# 설명: 원인(LOG_LEVEL)을 안 고치고 재시작만 하면 계속 죽는다
# 실패해야: 안정적으로 실행 중
# 실패해야: LOG_LEVEL 이 허용된 값
docker restart api
sleep 2
