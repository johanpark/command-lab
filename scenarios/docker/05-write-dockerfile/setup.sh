#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
S="$H/hello-site"; mkdir -p "$S/css"
team=$(rand_pick 플랫폼팀 인프라팀 데브옵스팀)
printf '<link rel="stylesheet" href="css/site.css">\n<h1>Hello!</h1>\n<a href="about.html">회사 소개</a>\n' > "$S/index.html"
printf '<h1>회사 소개</h1>\n<p>%s 이 만들었습니다. (빌드 번호 %s)</p>\n' "$team" "$(rand_int 100 999)" > "$S/about.html"
echo 'body { font-family: sans-serif; }' > "$S/css/site.css"
give "$S"
cp "$S/about.html" /opt/cmdlab/secret/about.html
