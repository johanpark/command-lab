# vim 을 비대화형(ex 모드)으로 써서 같은 편집을 한다
vim -es -c '%s/^port = 8080$/port = 9090/' -c 'g/^debug = true$/d' -c '$s/$/\rtimezone = Asia\/Seoul/' -c 'wq' ~/app.conf < /dev/null
cat ~/app.conf
