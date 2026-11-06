# 설명: tee 로 /etc/hosts 를 덮어쓰면 다른 줄이 모두 사라진다
# 실패해야: /etc/hosts 의 다른 줄
getent hosts api.internal | awk '{print $1}' > ~/answer.txt
echo '127.0.0.1  api.internal' | sudo tee /etc/hosts > /dev/null
