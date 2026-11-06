# 설명: stop 만 || true 로 감싸면 web 이 없을 때 rm 에서 또 멈춘다
# 실패해야: web 이 없을 때 배포해도
sed -i 's|^docker stop web$|docker stop web \|\| true|' ~/deploy.sh
grep -q '^docker stop web || true' ~/deploy.sh || sed -i 's|^docker run -d --name web|docker stop web \|\| true\ndocker rm web\ndocker run -d --name web|' ~/deploy.sh
~/deploy.sh 1.1 > /dev/null 2>&1
sleep 1
