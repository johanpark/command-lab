# 설명: timezone 을 맨 끝이 아니라 맨 위에 넣었다
# 실패해야: 맨 끝 줄이 timezone
vim -es -c '%s/^port = 8080$/port = 9090/' -c 'g/^debug = true$/d' -c '1s/^/timezone = Asia\/Seoul\r/' -c 'wq' ~/app.conf < /dev/null
