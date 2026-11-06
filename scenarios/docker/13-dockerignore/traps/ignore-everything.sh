# 설명: * 로 다 빼 버리면 웹사이트 파일까지 이미지에 안 들어간다
# 실패해야: public/index.html
cd ~/webapp
printf '%s\n' '*' > .dockerignore
docker build -q -t webapp:1.1 . > /dev/null 2>&1
