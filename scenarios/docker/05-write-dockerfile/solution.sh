cd ~/hello-site
printf 'FROM busybox\nCOPY . /www\nCMD ["httpd", "-f", "-p", "80", "-h", "/www"]\n' > Dockerfile
docker build -q -t hello-site:1.0 .
docker run -d --name site -p 8081:80 hello-site:1.0
sleep 1
