# 설명: httpd 에 -h /www 를 빼면 기본 폴더를 보여 줘서 소개 페이지가 안 나온다
# 실패해야: about.html 이 소개 페이지
cd ~/hello-site
printf 'FROM busybox\nCOPY . /www\nCMD ["httpd", "-f", "-p", "80"]\n' > Dockerfile
docker build -q -t hello-site:1.0 .
docker run -d --name site -p 8081:80 hello-site:1.0
sleep 1
