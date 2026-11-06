# 설명: 포트를 쓰는 프로세스를 다 죽이면 다른 서비스(metrics)까지 멈춘다
# 실패해야: metrics(9100)는 그대로
# 모범 풀이 먼저
sudo pkill -x metrics
