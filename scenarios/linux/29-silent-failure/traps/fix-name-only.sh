# 설명: 이름만 고치고 set -e 를 넣지 않으면 다음에 또 조용히 '배포 성공' 한다
# 실패해야: 즉시 멈추고
sed -i 's#^ARTIFACT=~/build/app-\$VERSION.tar.gz#ARTIFACT=~/build/app-v$VERSION.tar.gz#' ~/deploy.sh
~/deploy.sh 2.5.0
