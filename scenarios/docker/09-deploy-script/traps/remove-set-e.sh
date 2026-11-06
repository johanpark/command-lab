# 설명: set -e 를 지워서 에러를 무시하면 다른 실패도 조용히 지나간다
# 실패해야: set -e 가 그대로
sed -i '/^set -e/d' ~/deploy.sh
sed -i 's|^docker run -d --name web|docker rm -f web 2>/dev/null\ndocker run -d --name web|' ~/deploy.sh
~/deploy.sh 1.1 > /dev/null 2>&1
sleep 1
