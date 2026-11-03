# 설명: usermod 에 -a 를 빼면 jun 이 developers, audit 에서 빠진다
# 모범 풀이 먼저
# 실패해야: 원래 그룹
sudo usermod -G deploy jun
