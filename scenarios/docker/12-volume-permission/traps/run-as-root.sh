# 설명: 컨테이너를 root(-u 0)로 다시 띄우면 권한 문제는 사라지지만 위험하다
# 실패해야: root 가 아닌 사용자로
docker rm -f uploader > /dev/null
docker run -d --name uploader -u 0 -v /srv/uploads:/data/uploads --restart unless-stopped uploader:2.3 > /dev/null
sleep 4
