# 설명: index.html 만 COPY 하면 다른 페이지와 css 가 이미지에 없다
# 실패해야: about.html, css/site.css
cd ~/hello-site
printf 'FROM busybox\nCOPY index.html /www/\nCMD ["httpd", "-f", "-p", "80", "-h", "/www"]\n' > Dockerfile
docker build -q -t hello-site:1.0 .
docker run -d --name site -p 8081:80 hello-site:1.0
sleep 1
