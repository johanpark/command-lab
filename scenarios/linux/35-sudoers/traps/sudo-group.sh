# 설명: deploy 를 sudo 그룹에 넣으면 (비밀번호만 있으면) 뭐든 된다
# 모범 풀이 먼저
# 실패해야: app-restart 하나뿐
sudo usermod -aG sudo deploy
