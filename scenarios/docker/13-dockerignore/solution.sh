cd ~/webapp
printf '%s\n' .git .env '.env.*' node_modules logs '*.log' > .dockerignore
docker build -q -t webapp:1.1 . > /dev/null
docker images webapp
docker run --rm webapp:1.1 ls -la /app
