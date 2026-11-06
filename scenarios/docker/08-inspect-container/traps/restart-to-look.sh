# 설명: 들여다보려고 컨테이너를 멈추거나 지우면 안 된다
# 실패해야: legacy-app 은 그대로 실행 중
# 모범 풀이 먼저
docker stop legacy-app > /dev/null
