# 설명: 고친 다음에 조회하면 새 IP(127.0.0.1)를 옛 IP 로 적게 된다
# 실패해야: 원래 풀리던(옛) IP
# 모범 풀이 먼저
getent hosts api.internal | awk '{print $1}' > ~/answer.txt
