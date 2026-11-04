# 설명: vim 대신 sed 로 고쳐도 결과가 같으면 맞는 풀이다
# 통과해야
sed -i -e 's/^port = 8080$/port = 9090/' -e '/^debug = true$/d' ~/app.conf
echo 'timezone = Asia/Seoul' >> ~/app.conf
