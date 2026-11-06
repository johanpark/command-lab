# 설명: 범인을 죽이기만 하고 myapp 을 다시 띄우지 않았다
# 실패해야: 8080 포트에서 myapp 이 동작
name=$(sudo ss -Hltnp 'sport = :8080' | grep -o '(("[^"]*"' | cut -d'"' -f2)
echo "$name" > ~/answer.txt
sudo pkill -x "$name"
