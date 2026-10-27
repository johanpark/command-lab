#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect "~/hello-site/Dockerfile 이 있다" test -f "$H/hello-site/Dockerfile"
expect "Dockerfile 이 busybox 를 베이스로 쓴다" grep -qiE '^FROM +busybox' "$H/hello-site/Dockerfile"
expect "hello-site:1.0 이미지가 있다" docker image inspect hello-site:1.0
expect "이미지 안 /www 에 index.html, about.html, css/site.css 가 있다" docker run --rm hello-site:1.0 sh -c 'test -f /www/index.html && test -f /www/about.html && test -f /www/css/site.css'
info=$(docker inspect site --format '{{.State.Running}} {{.Config.Image}}' 2>/dev/null)
expect "site 컨테이너가 hello-site:1.0 으로 실행 중이다" test "$info" = "true hello-site:1.0"
if [ "$(curl -fs http://localhost:8081/about.html 2>/dev/null)" = "$(cat /opt/cmdlab/secret/about.html)" ]; then pass "http://localhost:8081/about.html 이 소개 페이지를 보여준다"
else fail "http://localhost:8081/about.html 이 소개 페이지를 보여준다 (포트 8081:80, httpd 의 -h /www 확인)"; fi
finish
