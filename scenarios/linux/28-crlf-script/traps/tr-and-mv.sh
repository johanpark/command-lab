# 설명: tr 로 새 파일을 만들어 mv 하면 실행 권한이 사라진다
# 실패해야: 실행 권한이 있다
cd ~/deploy
for f in $(grep -rl $'\r' --include='*.sh' .); do tr -d '\r' < "$f" > /tmp/x && mv /tmp/x "$f"; done
bash ./deploy.sh
