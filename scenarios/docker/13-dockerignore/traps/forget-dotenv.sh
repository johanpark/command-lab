# 설명: .dockerignore 에 숨김 파일 .env 를 빼먹으면 비밀번호가 이미지에 들어간다
# 실패해야: .env(비밀번호)가 이미지에 없다
cd ~/webapp
printf '%s\n' .git node_modules logs '*.log' > .dockerignore
docker build -q -t webapp:1.1 . > /dev/null
